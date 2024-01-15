// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract FileStorage is Ownable {
    struct File {
        string name;
        string fileHash;
        address owner;
        uint256 dateOS;
    }

    File[] files;

    mapping(address => uint256) internal ownerCountOfFiles;
    mapping(uint256 => string) internal fileIdWithHash;
    mapping(uint256 => string) internal fileIdWithName;
    mapping(uint256 => address) internal fileIdWithOwnerAddress;

    modifier onlyOwnerOfFileCanAccess(uint256 _fileId) {
        require(msg.sender == fileIdWithOwnerAddress[_fileId]);
        _;
    }

    event StoreFileEvent(
        string name,
        string fileHash,
        uint256 dateOS,
        address indexed owner
    );

    function StoreFile(
        string memory _name,
        string memory _fileHash,
        address _owner
    ) public {
        bool alreadyExist = false;
        address owner;

        for (uint256 i = 0; i < files.length; i++) {
            if (
                keccak256(abi.encodePacked(fileIdWithHash[i])) ==
                keccak256(abi.encodePacked(_fileHash))
            ) {
                alreadyExist = true;
                owner = fileIdWithOwnerAddress[i];
            }
        }

        if (alreadyExist) {
            revert("file already exists");
        } else {
            uint256 _dateOS = block.timestamp;
            files.push(File(_name, _fileHash, _owner, _dateOS));
            uint256 id = files.length + 1;
            fileIdWithHash[id] = _fileHash;
            fileIdWithName[id] = _name;
            fileIdWithOwnerAddress[id] = msg.sender;
            ownerCountOfFiles[msg.sender] += 1;
            emit StoreFileEvent(_name, _fileHash, _dateOS, _owner);
        }
    }

    function getFileByOwnerAddress(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256[] memory Ids = new uint256[](ownerCountOfFiles[_owner]);
        uint256 counter = 0;
        for (uint256 i = 0; i < files.length; i++) {
            if (fileIdWithOwnerAddress[i] == _owner) {
                Ids[counter] = i;
                counter++;
            }
        }

        return Ids;
    }

    function getOwnerFilesDetails(
        address _owner
    ) public view returns (string[] memory, string[] memory) {
        uint256[] memory Ids = getFileByOwnerAddress(_owner);
        uint256 counter = 0;
        string[] memory fileNames = new string[](Ids.length);
        string[] memory fileHashes = new string[](Ids.length);

        for (uint256 i = 0; i < files.length; i++) {
            for (uint256 j = 0; j < Ids.length; j++) {
                if (fileIdWithOwnerAddress[j] == fileIdWithOwnerAddress[i]) {
                    fileNames[counter] = fileIdWithName[j];
                    fileHashes[counter] = fileIdWithHash[j];
                    counter++;
                }
            }
        }

        return (fileNames, fileHashes);
    }
}
