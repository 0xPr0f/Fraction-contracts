// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title Fraction
/// @author 0xPr0f | edited and gotten from https://soulminter.m1guelpf.me/
/// @notice Barebones contract to mint Fraction NFTs
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract FractionNFT {
    /// @notice Thrown when trying to transfer a Fraction token
    error Fractionallybounded(string error);

    /// @notice Emitted when minting a Soulbound NFT
    /// @param from Who the token comes from. Will always be address(0)
    /// @param to The token recipient
    /// @param id The ID of the minted token
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    /// @notice The symbol for the token
    string public constant symbol = "FSOUL";

    /// @notice The name for the token
    string public constant name = "Fractioned Soul";

    /// @notice The owner of this contract (set to the deployer)
    address public immutable owner = msg.sender;

    /// @notice The price
    uint256 public immutable price = 0.2 ether;

    /// @notice Get the metadata URI for a certain tokenID
    mapping(uint256 => string) public tokenURI;

    /// @notice Get the owner of a certain tokenID
    mapping(uint256 => address) public ownerOf;

    /// @notice Get how many SoulMinter NFTs a certain user owns
    mapping(address => uint256) public balanceOf;
    /// @notice Get how much spent on NFT
    mapping(address => uint256) public amountSpent;
    mapping(address => bool) public isAdmin;
    /// @dev Counter for the next tokenID, defaults to 1 for better gas on first mint
    uint256 internal nextTokenId = 1;

    constructor() payable {
        isAdmin[msg.sender] = true;
    }

    /// @notice This function was disabled to make the token Fraction. Calling it will revert
    function approve(address, uint256) public virtual {
        revert Fractionallybounded("Fractionally bounded");
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true, "Not admin");
        _;
    }

    /// @notice This function was disabled to make the token Fraction Calling it will revert
    function isApprovedForAll(address, address) public pure {
        revert Fractionallybounded("Fractionally bounded");
    }

    /// @notice This function was disabled to make the token Fraction. Calling it will revert
    function getApproved(uint256) public pure {
        revert Fractionallybounded("Fractionally bounded");
    }

    /// @notice This function was disabled to make the token Fraction. Calling it will revert
    function setApprovalForAll(address, bool) public virtual {
        revert Fractionallybounded("Fractionally bounded");
    }

    /// @notice This function was disabled to make the token Fraction. Calling it will revert
    function transferFrom(
        address,
        address,
        uint256
    ) public virtual {
        revert Fractionallybounded("Fractionally bounded");
    }

    /// @notice This function was disabled to make the token Fraction. Calling it will revert
    function safeTransferFrom(
        address,
        address,
        uint256
    ) public virtual {
        revert Fractionallybounded("Fractionally bounded");
    }

    /// @notice This function was disabled to make the token Fraction. Calling it will revert
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual {
        revert Fractionallybounded("Fractionally bounded");
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    function addAdmin(address newAdmin) public onlyAdmin {
        require(isAdmin[newAdmin] == false, "Already Admin");
        isAdmin[newAdmin] = true;
    }

    /// @notice Mint a new Fraction NFT to tx.origin
    /// @param metaURI The URL to the token metadata
    function mint(address _to, string calldata metaURI)
        public
        payable
        onlyAdmin
    {
        require(_to.balance >= msg.value, "Not enough balance");
        require(msg.value >= price, "Not enough to pay");
        if (isAdmin[_to] == false) {
            require(balanceOf[_to] == 0, "can only mint once");
        }

        amountSpent[_to] += msg.value;
        unchecked {
            balanceOf[_to]++;
        }
        ownerOf[nextTokenId] = _to;
        tokenURI[nextTokenId] = metaURI;
        (bool success, ) = payable(address(this)).call{value: msg.value}("");
        require(success);
        emit Transfer(address(0), _to, nextTokenId++);
    }

    function selfDestruct() external onlyAdmin {
        selfdestruct(payable(owner));
    }

    fallback() external payable {}

    receive() external payable {}

    function redrawToken(address tokensInWallet) external {
        IERC20(tokensInWallet).transfer(
            owner,
            IERC20(tokensInWallet).balanceOf(address(this))
        );
    }

    function redrawMain() external {
        payable(owner).transfer(address(this).balance);
    }
}
