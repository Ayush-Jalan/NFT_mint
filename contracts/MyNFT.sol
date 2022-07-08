// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "./libraries/Base64.sol";

contract MyNFT is ERC721URIStorage{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs; 

    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Rabbit", "Dog", "Cat", "Lion", "Goat", "Fox", "Tiger", "Elephant", "Owl", "Whale", "Crocodile"];
    string[] secondWords  = ["Eats", "Drinks", "Snores", "Sees", "Hears", "Sleeps", "Touches", "Beats", "Plays", "Watches"];
    string[] thirdWords = ["Bottle", "Pen", "Eraser", "Phone", "TV", "Speaker", "Window", "Door", "Bag", "Plate", "Wire"];

    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];

    event NewNFTMinted(address sender, uint256 tokenID);

    constructor() ERC721("SquareNFT", "SQUARE"){
        console.log("This is NFT contract");
    }

    function pickRandomFirstWord(uint256 tokenID) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenID))));
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenID) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenID))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenID) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenID))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }

    function makeNFT() public {
        uint256 newItemID = _tokenIDs.current();

        string memory first = pickRandomFirstWord(newItemID);
        string memory second = pickRandomSecondWord(newItemID);
        string memory third = pickRandomThirdWord(newItemID);
        string memory combinedWord = string(abi.encodePacked(first, second, third));
        string memory randomColor = pickRandomColor(newItemID);

        string  memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        console.log("\n--------------------");
        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenURI
                )
            )
        );
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemID);
        _setTokenURI(newItemID, finalTokenURI);
        console.log("An NFT w/ ID %s has been minted to %s", newItemID, msg.sender);
        _tokenIDs.increment();
        emit NewNFTMinted(msg.sender, newItemID);
    }
}

//Create this url: https://rinkeby.rarible.com/token/0x18AF8F0501fB5cCC5aD8214346b7f9782AdE575a:0.
