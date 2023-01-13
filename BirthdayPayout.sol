pragma solidity ^0.8.0;

import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract BirthdayPayout {

// store name,address teammates
// get name, addresses of teammates
// send ether to address teammates on command only by owner

    string _name;

    address _owner;

    Teammate[] public _teammates;

    // 1 ETH
    uint256 constant PRESENT = 1000000000000000000;

    // With this mapping, you can check the year when the present was sent to the specific address,
    // if the value stored in the mapping is not equal to the current year,
    // it means that the present was not sent yet and the function can send it again.
    mapping(address => uint) public sent;

    struct Teammate {
        string name;
        address account;
        uint256 birthday;
    }

    constructor() public {
        _name="vlad";
        _owner = msg.sender;
    }

    function addTeammate(address account,string memory name,uint256 birthday) public onlyOwner {
        require(msg.sender != account,"Cannot add oneself");
        Teammate memory newTeammate = Teammate(name,account, birthday);
        _teammates.push(newTeammate);
        emit NewTeammate(account,name);
    }

    function sendPresents() public onlyOwner {
        // it is a good idea to check whether there are any teammates in the database
        uint256 today_year = BokkyPooBahsDateTimeLibrary.getYear(block.timestamp);
        require(getTeammatesNumber() > 0, "No teammates in the database");
        for (uint256 i = 0; i < getTeammatesNumber(); i++) {
            // check if birthday is today and if a present has not been sent this year
            if (checkBirthday(i) && sent[getTeammate(i).account] != today_year) {
                sendToTeammate(i);
                // mark present as sent for this year
                sent[getTeammate(i).account] = today_year;
                emit HappyBirthday(_teammates[i].name, _teammates[i].account);
            }
        }
    }

    function checkBirthday(uint256 index) view public returns(bool){
        uint256 birthday = getTeammate(index).birthday;
        (uint256 birthday_year, uint256 birthday_month,uint256 birthday_day) = getDate(birthday);
        uint256 today = block.timestamp;
        (uint256 today_year, uint256 today_month, uint256 today_day) = getDate(today);

        if(birthday_day == today_day && birthday_month==today_month && birthday_year != today_year ){
            return true;
        }
        return false;
    }

    function getDate(uint256 timestamp) view public returns(uint256 year, uint256 month, uint256 day){
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }




    function getTeammate(uint256 index) view public returns(Teammate memory){
        return _teammates[index];
    }

    function getTeam() view public returns(Teammate[] memory){
        return  _teammates;
    }

    function getTeammatesNumber() view public returns(uint256){
        return _teammates.length;
    }

    function sendToTeammate(uint256 index) public onlyOwner{
        // Check whether current balance if enough for sending a present
        require(address(this).balance >= PRESENT,"Contract balance is low");
        payable(_teammates[index].account).transfer(PRESENT);
    }

    function deposit() public payable{

    }

    modifier onlyOwner{
        require(msg.sender == _owner,"Sender should be the owner of contract");
        _;
    }

    event NewTeammate(address account, string name);

    event HappyBirthday(string name, address account);
}