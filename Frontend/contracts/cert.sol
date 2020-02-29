pragma solidity >=0.4.22 <0.6.0;

import "./Ownable.sol";
import "./SafeMath.sol";

contract Cert is Ownable {
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    
    event AdminAdded(address indexed _addr, uint adminIndex);
    event AdminRemoved(address indexed _addr, uint adminIndex);
    event AdminLimitChanged(uint _newLimit);
    event StudentAdded(string _email, bytes32 _firstName, bytes32 _lastName, bytes32 _commendation, grades _grade);
    event StudentRemoved(string _email);
    event StudentNameUpdated(string _email, bytes32 _newFirstName, bytes32 _newLastName);
    event StudentCommendationUpdated(string _email, bytes32 _newCommendation);
    event StudentGradeUpdated(string  _email, grades _newgrade);
    event StudentEmailUpdated(string _email, string _newEmail);
    event AssignmentAdded(string _email, string _link, assignmentStatus _status, uint16 assignmentIndex);
    event AssignmentUpdated(string _email, assignmentStatus _status, uint16 assignmentIndex);
    event Donate(address _addr, uint _value);
    
    uint public maxAdmins = 0;
    uint public adminIndex = 0;
    uint public studentIndex = 0;
    
    enum  grades {Good, Great, Outstanding, Epic, Legendary}
     
    enum assignmentStatus {Inactive, Pending, Completed, Cancelled}
    
    struct Admin {
         bool authorized;
         uint id;
    }
     
    struct Assignment {
         string link;
         assignmentStatus status;
    }
     
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
     
    mapping (address => Admin) public admins;
    mapping (uint => address) public adminsReverseMapping;
    mapping (uint => Student) public students;
    mapping (string => uint) private studentsReverseMapping;
    
    constructor () public {
       maxAdmins = 2;
       _addAdmin(msg.sender);
        
    }
    
    modifier onlyAdmins() {
         require(admins[msg.sender].authorized == true, 'Only admins is allowed to call this function');
         _;
    }
    
    modifier onlyNonOwnerAdmins(address _addr) {
         require(adminsReverseMapping[admins[_addr].id] != owner());
         _;
    } 
    
    modifier onlyPermissibleAdminLimit() {
        require(adminIndex < maxAdmins, 'admins max reached');
        _;
    }
    
    modifier onlyNonExistentStudents(string memory _email) {
      require(keccak256(abi.encodePacked(students[studentsReverseMapping[_email]].email)) != keccak256(abi.encodePacked( _email)), 'email already exist');
        _;
    }
    
    modifier onlyValidStudents(string memory _email) {
      require( keccak256(abi.encodePacked(students[studentsReverseMapping[_email]].email)) == keccak256(abi.encodePacked( _email)), 'email not found');
        _;
    }
    
    function addAdmin(address _addr) public onlyOwner onlyPermissibleAdminLimit() {
         _addAdmin(_addr);
        emit AdminAdded( _addr, adminIndex);
    }

    function _addAdmin(address _addr) internal {
        if(admins[_addr].authorized == true) {}
        else {
        admins[_addr].authorized = true;    
        }
        admins[_addr].id = adminIndex;
        adminsReverseMapping[adminIndex] = _addr;
        adminIndex = adminIndex.add(1);
    }
    
    function removeAdmin(address _addr) public onlyOwner {
        require(_addr != msg.sender);
        _removeAdmin(_addr);
        emit AdminRemoved(_addr, adminIndex);
    }
    
    function _removeAdmin(address _addr) private  {
        if (adminIndex == 1) {
            revert('admin must be present');
        }
        if(admins[_addr].authorized == true){}
        //uint 
        admins[adminsReverseMapping[adminIndex - 1]].id = admins[_addr].id;
        adminsReverseMapping[admins[_addr].id] = adminsReverseMapping[adminIndex - 1];
        delete admins[_addr];
        delete adminsReverseMapping[adminIndex -1];
        adminIndex = adminIndex.sub(1);
    }
   
    function changeAdminLimit (uint _newLimit) public  {
        require(_newLimit > 1 && _newLimit > adminIndex);
        maxAdmins = _newLimit;
        emit AdminLimitChanged( _newLimit);
    }
   
    function transferOwnership (address _addr)  public {
        _removeAdmin(msg.sender);
        _addAdmin(_addr);
        super.transferOwnership(_addr);
    }
    
    function renounceOwnership() public {
        _removeAdmin(msg.sender);
        super.renounceOwnership();
    }
    
    function addStudent(bytes32 _firstName, bytes32 _lastName, bytes32 _commendation, grades _grade, string memory _email) public onlyAdmins onlyNonExistentStudents(_email)  {
        Student memory stud;
        stud.assignmentIndex = 0;
        stud.firstName = _firstName;
        stud.lastName = _lastName;
        stud.commendation = _commendation;
        stud.grade = _grade;
        stud.email = _email;
        stud.active = true;
        students[studentIndex] = stud;
        studentsReverseMapping[_email] = studentIndex;
        studentIndex = studentIndex.add(1);
        emit StudentAdded(_email,_firstName, _lastName, _commendation, _grade);
    }
    
    function removeStudent(string memory _email) public  onlyAdmins onlyValidStudents(_email)  {
      students[studentsReverseMapping[_email]].active = false;
      emit StudentRemoved(_email);
    }
    
    function changeStudentName(string memory _email, bytes32 _newFirstName, bytes32 _newLastName) public onlyAdmins onlyValidStudents(_email) {
        students[studentsReverseMapping[_email]].firstName = _newFirstName;
        students[studentsReverseMapping[_email]].lastName = _newLastName;
       emit StudentNameUpdated(_email, _newFirstName, _newLastName);
    }
    
    function changeStudentCommendation(string memory _email, bytes32 _newCommendation) public onlyAdmins onlyValidStudents(_email) {
        students[studentsReverseMapping[_email]].commendation = _newCommendation;
       emit StudentCommendationUpdated(_email, _newCommendation);
    }
    
    function changeStudentGrade(string memory _email, grades _newgrade) public onlyAdmins onlyValidStudents(_email) {
        students[studentsReverseMapping[_email]].grade = _newgrade;
        emit StudentGradeUpdated( _email, _newgrade);
    }
    
    function changeStudentEmail(string memory _email, string memory _newEmail) public onlyAdmins onlyValidStudents(_email) {
        students[studentsReverseMapping[_email]].email = _newEmail;
        emit StudentEmailUpdated(_email, _newEmail);
    } 
    
    function _calcAndFetchAssignmentIndex(Student storage scholar, bool isFinalProject) internal  returns(uint16) {
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
    
    function addAssignment(string memory _email, string memory _link, assignmentStatus _status, bool isFinalProject) public onlyAdmins onlyValidStudents(_email) {
        _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], isFinalProject);
        students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex] = Assignment(_link, _status);
        uint16 assignmentIndex =  students[studentsReverseMapping[_email]].assignmentIndex;
        emit AssignmentAdded(_email, _link, _status, assignmentIndex);
    }
    
    function updateAssignmentStatus(string memory _email, assignmentStatus _status, bool isFinalProject) public onlyAdmins onlyValidStudents(_email) {
       _calcAndFetchAssignmentIndex(students[studentsReverseMapping[_email]], isFinalProject);
       students[studentsReverseMapping[_email]].assignments[students[studentsReverseMapping[_email]].assignmentIndex].status = _status;
        uint16 assignmentIndex =  students[studentsReverseMapping[_email]].assignmentIndex;
        emit AssignmentUpdated(_email, _status, assignmentIndex);
    }
    
    function getAssignmentInfo(string memory _email, uint16 _assignmentIndex) view public onlyValidStudents(_email) returns(string memory link, assignmentStatus status ) {
        require(students[studentsReverseMapping[_email]].assignmentIndex >= 0);
        require(students[studentsReverseMapping[_email]].assignmentIndex >= _assignmentIndex, 'assignmentIndex above current Id');
        return(students[studentsReverseMapping[_email]].assignments[_assignmentIndex].link, students[studentsReverseMapping[_email]].assignments[_assignmentIndex].status);
    }
    
    function () external payable {
    }
    
    function donateEth() external payable {
      require(msg.value >= 0.005 ether);
    emit Donate(address(this), msg.value);
    }
    
    function withdrawEth() public payable onlyOwner {
      address payable _owner = address(uint160(owner()));
      uint bal = address(this).balance;
      _owner.transfer(bal);
      emit Donate(msg.sender, bal);
    }
    
}
