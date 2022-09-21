pragma solidity ^0.8.9;

contract CampaignFactory {
    address payable[] public deployedCampaigns;

    function createCampaign(uint min) public {
        // why address ?????
        address newCampaign = address(new Campaign(msg.sender, min));
        deployedCampaigns.push(payable(newCampaign));
    }

    function getDeployedContracts()public view returns(address payable[] memory){
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request{
        string description;
        uint value;
        address recepient;
        bool complete;
        uint approvalCount;
        mapping(address => bool)approvals;
    }
    
    address public manager;
    uint public minContribution;
    Request[] public requestList;
    mapping(address => bool) public approvers;
    uint public approversCount;

    constructor(address creator, uint minimumContribution){
        manager = creator;
        minContribution = minimumContribution;
    }

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    function contribute() public payable{
        require(msg.value > minContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string memory newDescription, uint newValue, address newRecepient)public restricted{
        Request storage newRequest = requestList.push();
        newRequest.description = newDescription;
        newRequest.value = newValue;
        newRequest.recepient = newRecepient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    // need calrification
    function approveRequest(uint index)public{
        Request storage request = requestList[index];
        
        require(approvers[msg.sender]);
        require(!(request.approvals[msg.sender]));

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    // need calrification
    function finalizeRequest(uint index)public restricted{
        Request storage request = requestList[index];

        require(request.approvalCount > (approversCount/2));
        require(!request.complete);

        payable(request.recepient).transfer(request.value);
        request.complete = true;
    }

    // need calrification
    function getSummary()public view returns(uint, uint, uint, uint, address){
        return (minContribution,
                address(this).balance,
                requestList.length,
                approversCount,
                manager);
    }

    function getRequestCount()public view returns(uint){
        return requestList.length;
    }
}