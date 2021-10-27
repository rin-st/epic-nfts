// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // We split the SVG at the part where it asks for the background color.
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 500 500"><rect width="100%" height="100%" fill="white"/><line x1="100" y1="0" x2="100" y2="500" stroke="#ddd"/><line x1="200" y1="0" x2="200" y2="500" stroke="#ddd"/><line x1="300" y1="0" x2="300" y2="500" stroke="#ddd"/><line x1="400" y1="0" x2="400" y2="500" stroke="#ddd"/><line x1="0" y1="100" x2="500" y2="100" stroke="#ddd"/><line x1="0" y1="200" x2="500" y2="200" stroke="#ddd"/><line x1="0" y1="300" x2="500" y2="300" stroke="#ddd"/><line x1="0" y1="400" x2="500" y2="400" stroke="#ddd"/><polygon points="';
  string svgPartTwo = '" style="fill:transparent;stroke:rgb(16, 144, 248);stroke-width:1"/>';

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("TriangleNFT", "TRIANGLE") {
    console.log("This is my NFT contract. Woah!");
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len;
    while (_i != 0) {
        k = k-1;
        uint8 temp = (48 + uint8(_i - _i / 10 * 10));
        bytes1 b1 = bytes1(temp);
        bstr[k] = b1;
        _i /= 10;
    }
    return string(bstr);
  }

  function pickRandom(uint256 tokenId, string memory str) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(str, Strings.toString(tokenId), abi.encodePacked(msg.sender))));
    rand = ((rand % 4) + 1) * 100;
    return uint2str(rand);
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function getTotalNFTsMinted() public view returns (uint256) {
    return _tokenIds.current();
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    require(
            newItemId < 50,
            "NFT Limit of 50 exceeded"
        );

    string memory firstX = pickRandom(newItemId, "FIRST_X");
    string memory secondX = pickRandom(newItemId, "SECOND_X");
    string memory thirdX = pickRandom(newItemId, "THIRD_X");
    string memory firstY = pickRandom(newItemId, "FIRST_Y");
    string memory secondY = pickRandom(newItemId, "SECOND_Y");
    string memory thirdY = pickRandom(newItemId, "THIRD_Y"); 
    string memory coordinates = string(abi.encodePacked(firstX, ',', firstY, ' ', secondX, ',', secondY, ' ', thirdX, ',', thirdY));

    string memory finalSvg = string(abi.encodePacked(svgPartOne, coordinates, svgPartTwo, "</svg>"));

    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    'Triangle: ',
                    // We set the title of our NFT as the generated word.
                    coordinates,
                    '", "description": "A highly acclaimed collection of triangles.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
          )
    );

    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
  
    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}