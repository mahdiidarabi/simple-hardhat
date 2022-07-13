// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Makan {
    address public owner;
    IERC20 public ramzRial;

    uint public rentingDuration = 2 minutes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    struct Room {
        uint id;
        uint agreementID;
        string telegramID;
        bool isVacant;
        address landLord;
        address renter;
        uint rentPerDay;
        uint collateral;
        bool isExisted;
    }

    struct Agreement {
        uint id;
        uint roomID;
        string telegramID;
        bool isActive;
        address landLord;
        address renter;
        uint rentPerDay;
        uint collateral;
        uint startingTime;
        bool isExisted;
    }

    uint currentRoomID = 0;
    mapping(uint => Room) public roomsByID;

    uint currentAgreementID = 0;
    mapping(uint => Agreement) public agreementsByID;

    constructor(
        address _ramzRial
    ) {
        ramzRial = IERC20(_ramzRial);
    }

    function addRoom(
        string memory _telegramID,
        uint _rentPerDay,
        uint _collateral
    ) public {
        roomsByID[currentRoomID] = Room(
            currentRoomID,
            0,
            _telegramID,
            true,
            msg.sender,
            address(0),
            _rentPerDay,
            _collateral,
            true
        );

        currentRoomID++;
    }

    function rentRoom(
        uint _roomID
    ) public {
        require(roomsByID[_roomID].isExisted == true, "No makan, No fun!");
        require(roomsByID[_roomID].isVacant == true, "Room is not vacant");

        uint totalFee = roomsByID[_roomID].rentPerDay + roomsByID[_roomID].collateral;

        require(ramzRial.balanceOf(msg.sender) >= totalFee, "No money, No fun!");
        require(ramzRial.allowance(msg.sender, address(this)) >= totalFee, "No approve!");

        Room memory theRoom = roomsByID[_roomID];

        ramzRial.transferFrom(msg.sender, address(this), totalFee);

        agreementsByID[currentAgreementID] = Agreement(
            currentAgreementID,
            _roomID,
            theRoom.telegramID,
            true,
            theRoom.landLord,
            msg.sender,
            theRoom.rentPerDay,
            theRoom.collateral,
            block.timestamp,
            true
        );

        roomsByID[_roomID].isVacant = false;
        roomsByID[_roomID].agreementID = currentAgreementID;
        roomsByID[_roomID].renter = msg.sender;

        currentAgreementID++;
    }

    function emptyRoom(
        uint _agreementID
    ) public {
        Agreement memory theAgreement = agreementsByID[_agreementID];

        require(theAgreement.isExisted == true, "There is no such agreement");
        require(theAgreement.isActive == true, "This Agreemtn has expired already.");
        require(block.timestamp >= theAgreement.startingTime + rentingDuration, "This agreement is not expired yet");

        Room memory theRoom = roomsByID[theAgreement.roomID];

        ramzRial.transfer(theAgreement.landLord, theAgreement.rentPerDay);
        ramzRial.transfer(theAgreement.renter, theAgreement.collateral);

        theRoom.isVacant = true;
        theRoom.renter = address(0);
        theRoom.agreementID = 0;

        roomsByID[theAgreement.roomID] = theRoom;

        agreementsByID[_agreementID].isActive = false;
    }
}