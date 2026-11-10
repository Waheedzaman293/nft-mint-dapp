// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LuxeNFT — sample ERC-721 minting contract
/// @notice A compact ERC-721 implementation with paid public minting,
///         per-wallet limit, base-URI metadata and owner withdraw.
///         Written as a portfolio sample for an NFT mint dApp.
contract LuxeNFT {
    string public name = "LuxeNFT";
    string public symbol = "LUXE";
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public mintPrice = 0.01 ether;
    uint256 public constant MAX_PER_WALLET = 5;
    bool public mintOpen = false;

    address public owner;
    string private _baseTokenURI;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(string memory baseURI_) {
        owner = msg.sender;
        _baseTokenURI = baseURI_;
    }

    // ---------- Minting ----------
    function mint(uint256 quantity) external payable {
        require(mintOpen, "Mint is not open");
        require(quantity > 0, "Quantity is zero");
        require(totalSupply + quantity <= MAX_SUPPLY, "Sold out");
        require(_balances[msg.sender] + quantity <= MAX_PER_WALLET, "Wallet limit");
        require(msg.value >= mintPrice * quantity, "Insufficient payment");

        for (uint256 i = 0; i < quantity; i++) {
            totalSupply++;
            _owners[totalSupply] = msg.sender;
            _balances[msg.sender]++;
            emit Transfer(address(0), msg.sender, totalSupply);
        }
    }

    // ---------- ERC-721 ----------
    function balanceOf(address account) external view returns (uint256) {
        require(account != address(0), "Zero address");
        return _balances[account];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        ownerOf(tokenId);
        return string(abi.encodePacked(_baseTokenURI, _toString(tokenId), ".json"));
    }

    function approve(address to, uint256 tokenId) external {
        address tokenOwner = ownerOf(tokenId);
        require(msg.sender == tokenOwner || _operatorApprovals[tokenOwner][msg.sender], "Not authorised");
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        ownerOf(tokenId);
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) external view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(ownerOf(tokenId) == from, "From is not the owner");
        require(
            msg.sender == from || msg.sender == _tokenApprovals[tokenId] || _operatorApprovals[from][msg.sender],
            "Not authorised"
        );
        require(to != address(0), "Zero address");
        delete _tokenApprovals[tokenId];
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x80ac58cd || interfaceId == 0x01ffc9a7; // ERC721, ERC165
    }

    // ---------- Admin ----------
    function setMintOpen(bool open_) external onlyOwner {
        mintOpen = open_;
    }

    function setMintPrice(uint256 price_) external onlyOwner {
        mintPrice = price_;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseTokenURI = baseURI_;
    }

    function withdraw() external onlyOwner {
        (bool ok, ) = payable(owner).call{value: address(this).balance}("");
        require(ok, "Withdraw failed");
    }

    // ---------- Helpers ----------
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
