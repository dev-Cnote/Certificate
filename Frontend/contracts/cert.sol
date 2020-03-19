pragma solidity >=0.4.22 <0.6.0;
import "./Ownable.sol";
import "./SafeMath.sol";
contract Cert is Ownable {
    
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    
    //EVENTS
    
    //Admin Related Events
    
    event AdminAdded(address indexed _addr, uint adminIndex);
    event AdminRemoved(address indexed _addr, uint adminIndex);
    event AdminLimitChanged(uint _newLimit);
    
    //Student Related Events
    
    event StudentAdded(string _email, bytes32 fName, bytes32 lName, bytes32 commd, grades _grade);
    event StudentRemoved(string _email);
    event StudentNameUpdated(string _email, bytes32 nFirstName, bytes32 nLastName);
    event StudentCommendationUpdated(string _email, bytes32 nCommendation);
    event StudentGradeUpdated(string  _email, grades _newgrade);
    event StudentEmailUpdated(string _email, string _newEmail);
    
    //Assignment Related Events
    
    event AssignmentAdded(string _email, string _link, assignmentStatus _status, uint16 assignmentIndex);
    event AssignmentUpdated(string _email, assignmentStatus _status, uint16 assignmentIndex);
    event Donate(address _addr, uint _value);
    event Donatee(address _addr, uint _value);
    
    //STATE VARIABLES
    
    //Initialising VARIABLES
    
    uint public maxAdmins = 0;
    uint public adminIndex = 0;
    uint public studentIndex = 0;
    uint public totalWeiDonations = 0;
    
    // ENUMS
    
    // ENUMS FOR THE STUDENT GRADE
    
    enum  grades {Good, Great, Outstanding, Epic, Legendary}
    
    // ENUMS FOR THE ASSIGNMENT STATUS
     
    enum assignmentStatus {Inactive, Pending, Completed, Cancelled}
    
    
    // STRUCTS
    
    // STRUCT FOR ADMINS
    
    struct Admin {
         bool authorized;
         uint id;
    }
     
    // STRUCT FOR ASSIGNMENT
    
    struct Assignment {
         string link;
         assignmentStatus status;
    }
    
    // STRUCT FOR STUDENT
     
    struct Student {
         bytes32 firstName;
         bytes32 lastName;
         bytes32 commendation;
         grades grade;
         uint16 assignmentIndex;
         bool active;
         string email;
        mapping (uint16 => Assignment) assignments;
    }
    
    // MAPPINGS
    
    mapping (address => Admin) public admins;
    mapping (uint => address) public adminsReverseMapping;
    mapping (uint => Student) private students;
    mapping (string => uint) private studentsReverseMapping;
    
    constructor () public {
       maxAdmins = 2;
       _addAdmin(msg.sender);
        
    }
    
    // MODIFIERS
    
    modifier onlyAdmins() {
         require(admins[msg.sender].authorized == true, 'Only admins is allowed to call this function');
         _;
    }
    
    modifier onlyNonOwnerAdmins(address _addr) { 
        require(admins[_addr].authorized = true, "Only admins allowed");
        require(_addr != owner(), "Only non-owner admin");
        _;
    }
     
    
    modifier onlyPermissibleAdminLimit() {
        require(adminIndex < maxAdmins, 'admins max reached');
        _;
    }
    
    modifier onlyNonExistentStudents(string memory _email) {
         require(!students[studentsReverseMapping[_email]].active, "Student already Exists");
      require(keccak256(abi.encodePacked(students[studentsReverseMapping[_email]].email)) != keccak256(abi.encodePacked( _email)), 'email already exist');
        _;
    }
    
    modifier onlyValidStudents(string memory _email) {
         require(students[studentsReverseMapping[_email]].active, "Student doesn't exists");
      require( keccak256(abi.encodePacked(students[studentsReverseMapping[_email]].email)) == keccak256(abi.encodePacked( _email)), 'email not found');
        _;
    }
    
   // FUNCTIONS
   
   // ADMIN RELATED FUNCTIONS
    
    function addAdmin(address _addr) external onlyOwner onlyPermissibleAdminLimit() {
         _addAdmin(_addr);
        emit AdminAdded( _addr, adminIndex);
    }
    function _addAdmin(address _addr) private {
       if(admins[_addr].authorized == false) {
        admins[_addr].authorized = true;    
        admins[_addr].id = adminIndex;
        adminsReverseMapping[adminIndex] = _addr;
        adminIndex = adminIndex.add(1);
      }
    }
    
    function removeAdmin(address _addr) external onlyOwner onlyNonOwnerAdmins( _addr) {
        _removeAdmin(_addr);
        emit AdminRemoved(_addr, adminIndex);
    }
    
    function _removeAdmin(address _addr) private  {
        // Function will run even if the admin is not authorized, so a fake addres will also result in decreasing adminIndex
        // run it inside the autorize conditional logic
        // also, the function will run well for 2 admins but will be incorrect when the number increses
        // since the last adminIndex is getting swapped with the second last admin index
        // revisit this
        
        // Suggestable Logic :
        
        
        if (adminIndex == 1) {
            revert('admin must be present');
        }
        
        if (admins[_addr].authorized = true) {
            // get id of the admin to be deleted
            uint swappableId = admins[_addr].id;
            
            // swap the admins info and update admins mapping
            // get the last adminsReverseMapping address for swapping
            address swappableAddress = adminsReverseMapping[adminIndex -1];
            
            // swap the adminsReverseMapping and then reduce admin index
            adminsReverseMapping[swappableId] = adminsReverseMapping[adminIndex - 1];
            
            // also remap the admins id
            admins[swappableAddress].id = swappableId;
            
            // delete and reduce admin index 
            delete(admins[_addr]);
            delete(adminsReverseMapping[adminIndex - 1]);
            adminIndex = adminIndex.sub(1);
            
            // Emit event
            emit AdminRemoved(_addr, adminIndex);
        }
    }
   
    function changeAdminLimit (uint _newLimit) external  {
        require(_newLimit >= 1 && _newLimit > adminIndex);
        maxAdmins = _newLimit;
        emit AdminLimitChanged( _newLimit);
    }
   
    function transferOwnership (address _addr) onlyOwner public {
        _removeAdmin(msg.sender);
        _addAdmin(_addr);
        super.transferOwnership(_addr);
    }
    
    function renounceOwnership() public {
        _removeAdmin(msg.sender);
        super.renounceOwnership();
    }
    
    // STUDENT RELATED FUNCTIONS
    
    function addStudent(string calldata _firstName, string calldata _lastName, string calldata _commendation, grades _grade, string calldata _email) external onlyAdmins onlyNonExistentStudents(_email)  {
        bytes32 fName = stringToBytes32(_firstName);
        bytes32 lName = stringToBytes32(_lastName);
        bytes32 commd = stringToBytes32(_commendation);
        
        Student memory stud;
        stud.assignmentIndex = 0;
        stud.firstName = fName;
        stud.lastName = lName;
        stud.commendation = commd;
        stud.grade = _grade;
        stud.email = _email;
        stud.active = true;
        students[studentIndex] = stud;
        
        studentsReverseMapping[_email] = studentIndex;
        studentIndex = studentIndex.add(1);
        
        emit StudentAdded(_email,fName, lName, commd, _grade);
    }
    
    function searchStudent(string calldata _email) external view returns(string memory firstName, string memory lastName, string memory commendation, grades grade, uint16 assignmentIndex, bool active) {
        return(
            bytes32ToString(students[studentsReverseMapping[_email]].firstName),bytes32ToString(students[studentsReverseMapping[_email]].lastName),
            bytes32ToString(students[studentsReverseMapping[_email]].commendation),students[studentsReverseMapping[_email]].grade,
            students[studentsReverseMapping[_email]].assignmentIndex, students[studentsReverseMapping[_email]].active
            );
    }
    
    function removeStudent(string calldata _email) external  onlyAdmins onlyValidStudents(_email)  {
      students[studentsReverseMapping[_email]].active = false;
      emit StudentRemoved(_email);
    }
    
    function changeStudentName(string calldata _email, string calldata _newFirstName, string calldata _newLastName) external onlyAdmins onlyValidStudents(_email) {
        bytes32 nFirstName = stringToBytes32(_newFirstName);
        bytes32 nLastName = stringToBytes32(_newLastName);
        
        students[studentsReverseMapping[_email]].firstName = nFirstName;
        students[studentsReverseMapping[_email]].lastName = nLastName;
        
       emit StudentNameUpdated(_email, nFirstName, nLastName);
    }
    
    function changeStudentCommendation(string calldata _email, string calldata _newCommendation) external onlyAdmins onlyValidStudents(_email) {
       bytes32 nCommendation = stringToBytes32(_newCommendation);
       
       students[studentsReverseMapping[_email]].commendation = nCommendation;
       emit StudentCommendationUpdated(_email, nCommendation);
    }
    
    function changeStudentGrade(string calldata _email, grades _newgrade) external onlyAdmins onlyValidStudents(_email) {
        students[studentsReverseMapping[_email]].grade = _newgrade;
        emit StudentGradeUpdated( _email, _newgrade);
    }
    
    function changeStudentEmail(string calldata _email, string calldata _newEmail) external onlyAdmins onlyValidStudents(_email) {
        students[studentsReverseMapping[_email]].email = _newEmail;
        emit StudentEmailUpdated(_email, _newEmail);
    } 
    
    // ASSIGNMENT RELATED FUNCTIONS
    
    // TO CHECK WHETHER IS FINAL PROJECT OR NOT
    
    function _calcAndFetchAssignmentIndex(Student storage scholar, bool isFinalProject) private  returns(uint16) {
       uint16 assignmentIndex;
        
        if(isFinalProject == true) {
          assignmentIndex = 0; 
        }
        else if (isFinalProject == false) {
          scholar.assignmentIndex = scholar.assignmentIndex.add(1);
          assignmentIndex = scholar.assignmentIndex;
        }
        
         
        return assignmentIndex;
    }
    
    function addAssignment(string calldata _email, string calldata _link, assignmentStatus _status, bool isFinalProject) external onlyAdmins onlyValidStudents(_email) {
        uint16 assignmentIndex = _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], isFinalProject);
        students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex] = Assignment(_link, _status);
        
        emit AssignmentAdded(_email, _link, _status, assignmentIndex);
    }
    
    function updateAssignmentStatus(string calldata _email, assignmentStatus _status, bool isFinalProject) external onlyAdmins onlyValidStudents(_email) {
      uint16 assignmentIndex = _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], isFinalProject);
       students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex].status = _status;
          
        emit AssignmentUpdated(_email, _status, assignmentIndex);
    }
    
    function getAssignmentInfo(string calldata _email, uint16 _assignmentIndex) view external onlyValidStudents(_email) returns(string memory link, assignmentStatus status ) {
        require(students[studentsReverseMapping[_email]].assignmentIndex >= 0);
        require(_assignmentIndex <= students[studentsReverseMapping[_email]].assignmentIndex, 'assignmentIndex above current Id');
        return(students[studentsReverseMapping[_email]].assignments[_assignmentIndex].link, students[studentsReverseMapping[_email]].assignments[_assignmentIndex].status);
    }
   
   //FALLBACK 
   
    function () external payable {
    }
    
    // DONATE ETHER TO THE CONTRACT
    
    function donateEth() external payable {
      require(msg.value >= 0.005 ether);
    emit Donate(address(this), msg.value);
    }
    
    // WITHDRAW ETHER TO OWNER ADDRESS
    
    function withdrawEth() external payable onlyOwner {
      address payable _owner = address(uint160(owner()));
      uint bal = address(this).balance;
      _owner.transfer(bal);
      emit Donatee(msg.sender, bal);
    }
    
    //HELPER FUNCTIONS
    
    //CONVERT BYTES32 TO STRING
    
      function bytes32ToString(bytes32 _x) 
    private pure 
    returns (string memory result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        
        result = string(bytesStringTrimmed);
    }
    
    // CONVERT STRING TO BYTES32
    
       function stringToBytes32(string memory _source) 
    private pure 
    returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(_source);
        string memory tempSource = _source;
        
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(tempSource, 32))
        }
    }

}









