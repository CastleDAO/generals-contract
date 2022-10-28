// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IConnector {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract GeneralWeapons is
    ERC721Enumerable,
    ReentrancyGuard,
    Ownable,
    AccessControl
{
    bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");

    // Castles contract
    address public generalsAddress;
    IConnector public generalsContract;

    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

    // Castles contract
    struct weapon {
        string name;
        uint256 defense;
        uint256 strength;
        uint256 intelligence;
        uint256 agility;
        uint256 abilityPower;
        uint256 magicResistance;
        uint256 constitution;
        uint256 speed;
        uint256 createdAt;
    }

    // Global constants
    bool public paused = false; // Enable disable

    // Mappings
    mapping(uint256 => weapon) public weapons;

    // Events
    event WeaponCreated(string name, uint256 weaponId, weapon weaponCreated);

    event WeaponEquiped(
        address indexed user,
        uint256 generalId,
        uint256 weaponId
    );

    constructor(address _generalsAddress)
        ERC721("CastleDAO Weapons 1", "Weapons Level 1")
        Ownable()
    {
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        generalsAddress = _generalsAddress;
        generalsContract = IConnector(_generalsAddress);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Pause or resume minting
    function flipPause() public onlyOwner {
        paused = !paused;
    }

    // Claim deposited eth
    function ownerWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function mint(weapon w, address target) public nonReentrant {
        require(hasRole(GAME_ROLE, msg.sender), "Does not have permission");
        require(!paused, "Minting is paused");

        _internalMint(w, target);
    }

    // Called by every function after safe access checks
    function _internalMint(weapon memory _weapon, address target)
        internal
        returns (uint256)
    {
        require(
            bytes(weapon._name).length < 80 && bytes(weapon._name).length > 3,
            "Name between 3 and 100 characters"
        );

        // minting logic
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        weapons[tokenId] = _weapon;
        weapons[tokenId].createdAt = block.timestamp;

        emit WeaponCreated(_weapon.name, tokenId, _weapon);

        _safeMint(_msgSender(), tokenId);
        return tokenId;
    }

    // Equip weapon
    function equipWeapon(uint256 weaponId, uint256 generalId) public {
        require(
            _isApprovedOrOwner(msg.sender, weaponId),
            "Not the owner of the weapon"
        );

        require(
            generalsContract.ownerOf(generalId) == msg.sender,
            "Not the owner of this general"
        );

        emit WeaponEquiped(msg.sender, generalId, weaponId);

        transferFrom(msg.sender, ZERO_ADDRESS, weaponId);
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    string private baseURI = "ipfs://";

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }
}
