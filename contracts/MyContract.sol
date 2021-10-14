// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract MyContract is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter _tokenIds;

    struct general {
        string name;
        uint256 defense;
        uint256 strength;
        uint256 intelligence;
        uint256 agility;
        uint256 abilityPower;
        uint256 magicResistance;
        uint256 constitution;
        uint256 speed;
        uint256 charisma;
        // TODO: look at rarity manifested 
        uint256 level;
        uint256 createdAt;
        bool partner;
    }

    uint256 public priceChangeName = 10000000000000000; // 0.01 ETH
    uint256 public price = 50000000000000000; //0.05 ETH
    bool public paused = false; // Enable disable
    uint256 public maxTokens = 10000;

    mapping(uint256 => general) public generals;
    mapping(uint256 => uint256) public experience;


    event GeneralCreated(
        string name, 
        uint256 defense,
        uint256 strength,
        uint256 intelligence,
        uint256 agility,
        uint256 abilityPower,
        uint256 magicResistance,
        uint256 constitution,
        uint256 speed,
        uint256 charisma);

    event LevelUp(address indexed leveler, uint generalId, uint32 strength, uint32 dexterity, uint32 constitution, uint32 intelligence, uint32 wisdom, uint32 charisma);
    
    event NameChanged(uint generalId, string name);

    constructor() ERC721("CryptoGenerals", "CRYPTOGENERALS") Ownable() {}


    function spendExperience(uint256 _tokenId, uint256 _experience) external {
        require(_experience <= experience[_tokenId], "Not enough experience");
        require(_isApprovedOrOwner(msg.sender, _tokenId));

        experience[_tokenId] -= _experience;

        emit ExperienceSpent(_tokenId, _experience, experience[_tokenId]);
    }

    function changeName(uint256 _tokenId, string memory _name) external payable nonReentrant {
        require(msg.value >= priceChangeName, "Eth sent is not enough");
        require(_tokenId > 5 && _tokenId <= supply, "_tokenId invalid");
        require(!_exists(_tokenId), "_tokenId invalid");

        generals[_tokenId].name = _name;
        // Increase experience
        experience[_tokenId] += 100;
        emit NameChanged(_tokenId, _name);
    }

    // Create general
  function _createGeneral(
    uint256 _tokenId,
    string memory _name
  ) internal {
     
    generals[_tokenId].name = _name;
    generals[_tokenId].defense = _randomFromString("defense", 10);
    generals[_tokenId].strength = _randomFromString("strength", 10);
    generals[_tokenId].intelligence = _randomFromString("intelligence", 10);
    generals[_tokenId].agility = _randomFromString("agility", 10);
    generals[_tokenId].abilityPower = _randomFromString("abilityPower", 10);
    generals[_tokenId].magicResitance = _randomFromString("magicResitance", 10);
    generals[_tokenId].constitution = _randomFromString("constitution", 10);
    generals[_tokenId].speed = _randomFromString("speed", 10);
    generals[_tokenId].charisma = _randomFromString("charisma", 10);
    
    generals[_tokenId].level = 0;
    generals[_tokenId].createdAt = block.timestamp;

    experience[_tokenId].experience = 0;



    emit GeneralCreated(
        generals[_tokenId].name,
        generals[_tokenId].defense,
        generals[_tokenId].strength,
        generals[_tokenId].intelligence,
        generals[_tokenId].agility,
        generals[_tokenId].abilityPower,
        generals[_tokenId].magicResitance,
        generals[_tokenId].constitution,
        generals[_tokenId].speed,
        generals[_tokenId].charisma
    );
  }


   function _increase_base(uint _tokenId) internal {
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(character_created[_tokenId]);
        uint _points_spent = level_points_spent[_tokenId];
        require(abilities_by_level(rm.level(_tokenId)) - _points_spent > 0);
        level_points_spent[_tokenId] = _points_spent+1;
    }

    function increase_strength(uint _tokenId) external {
        _increase_base(_tokenId);
        ability_score storage _attr = ability_scores[_tokenId];
        _attr.strength = _attr.strength+1;
        emit Leveled(msg.sender, _tokenId, _attr.strength, _attr.dexterity, _attr.constitution, _attr.intelligence, _attr.wisdom, _attr.charisma);
    }

    // Pause or resume minting
    function flipPause() public onlyOwner {
        paused = !paused;
    }

    // Change the public price of the token
    function setPublicPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    // Change the maximum amount of tokens
    function setMaxtokens(uint256 newMaxtokens) public onlyOwner {
        maxTokens = newMaxtokens;
    }

    // Claim deposited eth
    function ownerWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }


    string[] private types = [       
        "god",
        "demon",
        "chosenOne",
        "reincarnate",
        "wizard",
        "savage",
        "ai"
    ];
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

     function _random(uint256 _salt, uint256 _limit) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.number, block.timestamp, _salt))) % _limit;
    }

    function _randomFromString(string memory _salt, uint256 _limit) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.number, block.timestamp, _salt))) % _limit;
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
        return string(abi.encodePacked(bytes(_a), bytes(_b)));
    }
   
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // Returns a random item from the list, always the same for the same token ID
    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));

        return sourceArray[rand % sourceArray.length];
    }


    
    function getType(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        return pluck(tokenId, "TYPE", types);
    }

    function getIsSpecial(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        uint256 rand = random(string(abi.encodePacked("IS_SPECIAL", toString(tokenId))));
        return (rand % 99) < 10;
    }

    function getDefense(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        uint256 rand = random(string(abi.encodePacked("DEFENSE", toString(tokenId))));
        uint256 max = 50;
        uint256 min = 10;

        string memory cType = getType(tokenId);

        if (compareStrings(cType, "god")) {
            min = 20;
            max = 50;
        } else if (compareStrings(cType, "demon")) {
            min = 15;
            max = 40;
        } else if (compareStrings(cType, "ai")) {
            min = 20;
            max = 80;
        } else if (compareStrings(cType, "chosenOne")) {
            min = 25;
            max = 60;
        } else if (compareStrings(cType, "reincarnate")) {
            min = 20;
            max = 60;
        } else if (compareStrings(cType, "wizard")) {
            min = 50;
            max = 80;
        } else if (compareStrings(cType, "savage")) {
            min = 30;
            max = 80;
        }
        
        if (getIsSpecial(tokenId)) {
            min += 30;
            max += 20;
        }

        uint256 diff = max - min;

        return (rand % diff) + min;
    }

    function getAttack(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        uint256 rand = random(string(abi.encodePacked("ATTACK", toString(tokenId))));
        uint256 max = 50;
        uint256 min = 10;

        string memory cType = getType(tokenId);

        if (compareStrings(cType, "god")) {
            min = 20;
            max = 50;
        } else if (compareStrings(cType, "demon")) {
            min = 40;
            max = 80;
        } else if (compareStrings(cType, "ai")) {
            min = 50;
            max = 80;
        } else if (compareStrings(cType, "chosenOne")) {
            min = 30;
            max = 60;
        } else if (compareStrings(cType, "reincarnate")) {
            min = 20;
            max = 60;
        } else if (compareStrings(cType, "wizard")) {
            min = 20;
            max = 50;
        } else if (compareStrings(cType, "savage")) {
            min = 50;
            max = 90;
        }
        
        if (getIsSpecial(tokenId)) {
            min += 30;
            max += 20;
        }

        uint256 diff = max - min;

        return (rand % diff) + min;
    }

    function getSoul(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        uint256 rand = random(string(abi.encodePacked("SOUL", toString(tokenId))));
        uint256 max = 50;
        uint256 min = 10;

        string memory cType = getType(tokenId);

        if (compareStrings(cType, "god")) {
            min = 50;
            max = 100;
        } else if (compareStrings(cType, "demon")) {
            min = 30;
            max = 75;
        } else if (compareStrings(cType, "ai")) {
            min = 10;
            max = 40;
        } else if (compareStrings(cType, "chosenOne")) {
            min = 30;
            max = 50;
        } else if (compareStrings(cType, "reincarnate")) {
            min = 30;
            max = 70;
        } else if (compareStrings(cType, "wizard")) {
            min = 50;
            max = 70;
        } else if (compareStrings(cType, "savage")) {
            min = 20;
            max = 40;
        }
        
        if (getIsSpecial(tokenId)) {
            min += 30;
            max += 20;
        }

        uint256 diff = max - min;

        return (rand % diff) + min;
    }

    function getWisdom(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        uint256 rand = random(string(abi.encodePacked("WISDOM", toString(tokenId))));
        uint256 max = 50;
        uint256 min = 10;

        string memory cType = getType(tokenId);

        if (compareStrings(cType, "god")) {
            min = 50;
            max = 100;
        } else if (compareStrings(cType, "demon")) {
            min = 20;
            max = 70;
        } else if (compareStrings(cType, "ai")) {
            min = 20;
            max = 70;
        } else if (compareStrings(cType, "chosenOne")) {
            min = 20;
            max = 60;
        } else if (compareStrings(cType, "reincarnate")) {
            min = 60;
            max = 90;
        } else if (compareStrings(cType, "wizard")) {
            min = 60;
            max = 90;
        } else if (compareStrings(cType, "savage")) {
            min = 10;
            max = 30;
        }
        
        if (getIsSpecial(tokenId)) {
            min += 30;
            max += 20;
        }

        uint256 diff = max - min;

        return (rand % diff) + min;
    }

    function getRarityNumber(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        uint256 defense = getDefense(tokenId);
        uint256 attack = getAttack(tokenId);
        uint256 wisdom = getWisdom(tokenId);
        uint256 soul = getSoul(tokenId);

        bool special = getIsSpecial(tokenId);

        uint256 rarity = 0;

        if (special) {
            rarity += 1;
        }

        if (defense > 50) {
            rarity += 1;
            if (defense > 70) {
                rarity += 1;
                if(defense > 90 ) {
                    rarity += 1;
                }
            }
        }

        if (wisdom > 50) {
            rarity += 1;
            if (wisdom > 70) {
                rarity += 1;
                if(wisdom > 90 ) {
                    rarity += 1;
                }
            }
        }

        if (soul > 50) {
            rarity += 1;
            if (soul > 70) {
                rarity += 1;
                if(soul > 90 ) {
                    rarity += 1;
                }
            }
        }

        if (attack > 50) {
            rarity += 1;
            if (attack > 70) {
                rarity += 1;
                if(attack > 90 ) {
                    rarity += 1;
                }
            }
        }


        return rarity;
    }


    string[] private traitCategories = [
        "type",
        "defense",
        "wisdom",
        "soul",
        "attack",
        "rarityNumber",
        "special"
    ];
    
    function traitsOf(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: Non minted NFT");
        string[7] memory traitValues = [
            getType(tokenId),
            toString(getDefense(tokenId)),
            toString(getWisdom(tokenId)),
            toString(getSoul(tokenId)),
            toString(getAttack(tokenId)),
            toString(getRarityNumber(tokenId)),
            getIsSpecial(tokenId) ? 'true': 'false'
        ];

        string memory resultString = "[";
        for (uint8 j = 0; j < traitCategories.length; j++) {
        if (j > 0) {
            resultString = strConcat(resultString, ", ");
        }
        resultString = strConcat(resultString, '{"trait_type": "');
        resultString = strConcat(resultString, traitCategories[j]);
        resultString = strConcat(resultString, '", "value": "');
        resultString = strConcat(resultString, traitValues[j]);
        resultString = strConcat(resultString, '"}');
        }
        return strConcat(resultString, "]");
    }


    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    string private baseURI = "ipfs://asdad/asdas/";

    function _baseURI() override internal view virtual returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function mint() public payable nonReentrant {
        require(!paused, "Minting is paused");
        require(price <= msg.value, "Ether value sent is not correct");
        // minting logic
        uint256 current = _tokenIds.current();
        require(current <= maxTokens, "Max token reached");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _safeMint(_msgSender(), tokenId);
    }

   
    // Allow the owner to claim a nft 
    function ownerClaim() public nonReentrant onlyOwner {
        // minting logic
        require(_tokenIds.current() <= maxTokens, "Max token reached");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _safeMint(_msgSender(), tokenId);
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

   
}
