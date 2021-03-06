pragma solidity ^0.4.25;


// ----------------------------------------------------------------------------
// Deployed to : 
// Symbol      : 
// Name        : 
// Total supply: 
// Decimals    : 18
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract VegaToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(){
        
        symbol = "Vega";
        name = "Vega Token";
        decimals = 18;
        //bonusEnds = now + 1 weeks;
        

    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
   


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // 1,000 Santo Tokens per 1 ETH
    // ------------------------------------------------------------------------
    



    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

contract ICO is VegaToken(){
    uint public startDate;
    uint public endDate;
    uint public softCapICO;
    bool public isSale;
    uint public currentRound;
    address public myowner;
    bool public isRoundActive;
    uint public totalEthers;
    
    uint public totalTokens;
    uint public totalSupply;
    
    uint public totalAdvisorsTokens;
    uint public totalAdvisorsSupply;
    
    uint public totalTeamTokens;
    uint public totalTeamSupply;
    
    struct Details {
        string userType;
        uint tokenBalance;
        uint etherBalance;
        uint freezeTime;
    }
    mapping (address => Details) tokenOwners;
   
    struct Statistic {
        uint roundNumber;
        uint roundEther;
        uint roundTotalSupply;
        uint roundBonus;
        uint roundHardCap;
        uint roundSoftCap;
        uint roundStartTime;
        uint roundDuration;
    }
    

    //Statistic[] public rounds; 
    mapping(uint => Statistic) rounds;

    constructor(uint softCapArg, uint ICODurationInWeeks) {
        softCapICO = softCapArg;
        isSale = true;
        currentRound = 0;
        isRoundActive = false;
        startDate = now;
        endDate = now + (ICODurationInWeeks * 1 weeks);

    }
    

    function withdrawUserEther() public {
        require(isSale == false && totalEthers < softCapICO);
        address user = msg.sender;
        user.transfer(tokenOwners[user].etherBalance *1 ether);
    }
    
    function withdrawOwnerEther() public onlyOwner{
       require(totalEthers >= softCapICO);
        msg.sender.transfer(totalEthers * 1 ether);
    }
    function getCurrentRound() public returns (uint) {
        return currentRound;
    }

    function startRound(uint rhardCap) public onlyOwner{
        require(isSale == true);
        currentRound++;
        rounds[currentRound].roundStartTime = now;
        isRoundActive = true;
        
        rounds[currentRound].roundNumber = currentRound;
        rounds[currentRound].roundHardCap = rhardCap;
        rounds[currentRound].roundEther = 0;
    }

    function returnStatistics(uint roundno) public constant onlyOwner returns (uint, uint, uint, uint, uint, uint){
        
       return (rounds[roundno].roundNumber, rounds[roundno].roundHardCap, rounds[roundno].roundStartTime, rounds[roundno].roundDuration, rounds[roundno].roundEther, rounds[roundno].roundTotalSupply);
    }
    
    function endRound() public {
        isRoundActive = false;
        rounds[currentRound].roundDuration = now - rounds[currentRound].roundStartTime;

        if(rounds[currentRound].roundEther < rounds[currentRound].roundSoftCap){
            
        }
       // rounds.push(Statistic());
    }
    
    
    function () public payable {
        if(now >= endDate){
            isSale = false;
        }
        
        require(isSale == true && isRoundActive == true);
        uint convertToEther = msg.value / 1 ether;
        
        uint tokens;
        if(now <= rounds[currentRound].roundStartTime + 3 days){
            tokens = convertToEther * 1200;
        }
        else {
         tokens = convertToEther * 1000;   
        }
        
        tokenOwners[msg.sender].userType = "User";
        tokenOwners[msg.sender].etherBalance += convertToEther;
        tokenOwners[msg.sender].tokenBalance += tokens;
        tokenOwners[msg.sender].freezeTime = endDate + 30 days;
        
        rounds[currentRound].roundTotalSupply += tokens;
        rounds[currentRound].roundEther +=  convertToEther;
        
        totalTokens += tokens;
        totalEthers += convertToEther;
        
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        Transfer(address(0), msg.sender, tokens);
        
        
        if(rounds[currentRound].roundEther >= rounds[currentRound].roundHardCap){
            endRound();
        }
        
    }
    
     function transfer(address to, uint tokens, string typeofUser) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        
        tokenOwners[to].userType = typeofUser;
        tokenOwners[to].etherBalance = 0;
        tokenOwners[to].tokenBalance += tokens;
        tokenOwners[to].freezeTime = now + 365 days;
        return true;
    }
    
    function sendTokenToAdvisors(address advisorAddress, uint tokenAmount) public onlyOwner{
        transfer(advisorAddress, tokenAmount, "Advisor" );
    }
    function sendTokenToTeam(address teamAddress, uint tokenAmount) public onlyOwner{
        transfer(teamAddress, tokenAmount, "Team" );
    }
    


}


