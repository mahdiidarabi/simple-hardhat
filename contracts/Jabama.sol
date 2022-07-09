// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Makan {
    address public owner;
    IERC20 public ramzRial;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    struct Room {
        uint id;
        uint agreementId;
        string telegramId;
        bool isVacant;
        address landLord;
        address renter;
        uint rentPerDay;
        uint collateral;
        bool isExisted;
    }

    struct Agreement {
        uint id;
        uint roomId;
        string telegramId;
        bool isActive;
        address landLord;
        address renter;
        uint rentPerDay;
        uint collateral;
        uint startingTime;
        bool isExisted;
    }

    uint currentRoomId = 0; 
    mapping(uint => Room) public roomsByID;

    uint currentAgreementId = 0;
    mapping(uint => Agreement) public agreementsByID;


    constructor(
        address _ramzRail
    ) {
        ramzRial = IERC20(_ramzRail);
    }


    function addRoom(
        string memory _telegramID,
        uint _rentPerDay,
        uint _collateral
    ) public {
        roomsByID[currentRoomId] = Room(
            currentRoomId,
            0,
            _telegramID,
            true,
            msg.sender,
            address(0),
            _rentPerDay,
            _collateral,
            true
        );

        currentRoomId = currentRoomId + 1;
    }


    function rentRoom(
        uint _roomId
    ) public {
        require(roomsByID[_roomId].isExisted == true, "No makan no fun :)");

        require(roomsByID[_roomId].isVacant == true, "Pore :(");

        uint totalFee = roomsByID[_roomId].rentPerDay + roomsByID[_roomId].collateral;

        require(ramzRial.balanceOf(msg.sender) >= totalFee, "Pool nadari :P");

        require(ramzRial.allowance(msg.sender, address(this)) >= totalFee, "Ejaze bede lashi");

        Room memory theRoom = roomsByID[_roomId];

        ramzRial.transferFrom(msg.sender, theRoom.landLord, totalFee);

        agreementsByID[currentAgreementId] = Agreement(
            currentAgreementId,
            _roomId,
            theRoom.telegramId,
            true,
            theRoom.landLord,
            msg.sender,
            theRoom.rentPerDay,
            theRoom.collateral,
            block.timestamp,
            true
        );

        roomsByID[_roomId].isVacant = false;
        roomsByID[_roomId].agreementId = currentAgreementId; 

        currentAgreementId ++;

    }

    // agreementsByID[currentAgreementId].startingTime <= block.timestamp - 5 hours;
}