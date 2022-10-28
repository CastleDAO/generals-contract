
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";


pragma solidity ^0.8.0;

interface ITokenDescriptor {
  

    function getRace(uint256 tokenId) external view returns (uint256);

    function getClass(uint256 tokenId) external view returns (uint256);

    function getCapacity(uint256 tokenId) external view returns (uint256);
    
    function getSpeed(uint256 tokenId) external view returns (uint256);
    function getAgility(uint256 tokenId) external view returns (uint256);
    function getConstitution(uint256 tokenId) external view returns (uint256);
    function getStrength(uint256 tokenId) external view returns (uint256);
    function getIntelligence(uint256 tokenId) external view returns (uint256);
    function getDefense(uint256 tokenId) external view returns (uint256);
    function getMagicResistance(uint256 tokenId) external view returns (uint256);
    function getAbilityPower(uint256 tokenId) external view returns (uint256);
    function getAbilities(uint256 tokenId) external view returns ([uint256]);


    function modifyAttributes(bytes[] calldata manyGlasses) external;
}

interface ITokenToFighter {
    struct Fighter {
        uint256 race;
        uint256 class;
        uint256 capacity;
        uint256 agility;
        uint256 speed;
        uint256 constitution;
        uint256 strength;
        uint256 intelligence;
        uint256 defense;
        uint256 magicResistance;
        uint256 abilityPower;
    }

    function generateFighter(uint256 tokenId, ITokenDescriptor descriptor)
        external
        view
        returns (Fighter memory);
}

contract TokenToFighter is ITokenToFighter {
    function generateFighter(uint256 tokenId, ITokenDescriptor descriptor)
        external
        view
        override
        returns (Fighter memory)
    {

        return
            Fighter({
                race: descriptor.getRace(tokenId),
                class: descriptor.getClass(tokenId),
                capacity: descriptor.getCapacity(tokenId),
                agility: descriptor.getAgility(tokenId),
                speed: descriptor.getSpeed(tokenId),
                constitution: descriptor.getConstitution(tokenId),
                strength: descriptor.getStrength(tokenId),
                intelligence: descriptor.getIntelligence(tokenId),
                defense: descriptor.getDefense(tokenId),
                magicResistance: descriptor.getMagicResistance(tokenId),
                abilityPower: descriptor.getAbilityPower(tokenId)


            });
    }
}