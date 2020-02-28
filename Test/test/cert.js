
const Cert = artifacts.require('Cert');

const studNames = ["0x766963746f720000000000000000000000000000000000000000000000000000", "0x766963746f720000000000000000000000000000000000000000000000000000", "0x766963746f720000000000000000000000000000000000000000000000000000", "0x6368756b73000000000000000000000000000000000000000000000000000000"];
const emails = ["email", "newEmail"];
const grades = ["1", "2"];
const links = ["https", "http"];
const _status = ["1", "2"];
const fProject = ["true", "false"];

contract('Cert', (accounts) => {
        let cert = null;
        let [owner, nonOwner] = accounts;

        before(async() => {
                cert = await Cert.deployed();
        });

        it('Should create a new admin', async () => {
                const result = await cert.addAdmin(nonOwner, {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._addr, nonOwner);
        });

        it('Should give error if a nonOwner calls function and check adminLimit', async () => {
                await cert.changeAdminLimit(5, {from: owner});
                await cert.addAdmin(nonOwner, {from: owner});
                await shouldThrow(cert.addAdmin(nonOwner, {from: nonOwner}));
        });

        it('Should remove admin', async () => {
              const result =  await cert.removeAdmin(nonOwner, {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._addr,nonOwner);
        });

        it('Should add student', async () => {
                 const result =  await cert.addStudent(studNames[0],studNames[1], studNames[0], grades[1], emails[0], {from: owner});
                 assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._email, emails[0]);

                        //_firstName, _lastName, _commendation, _grade, _email, studNames[0],studNames[1], studNames[0], grades[1], emails[0]);
        });

         it('Should remove student', async () => {
              const result =  await cert.removeStudent(emails[0], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._email,emails[0]);
        });

        it('Should change student name', async () => {
              const result =  await cert.changeStudentName(emails[0], studNames[3], studNames[3], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._newFirstName, studNames[3]);
        });

         it('Should change student commendation', async () => {
              const result =  await cert.changeStudentCommendation(emails[0], studNames[3], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._newCommendation, studNames[3]);
        });

         it('Should change student grade', async () => {
              const result =  await cert.changeStudentGrade(emails[0], grades[0], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._newgrade, grades[0]);
        });


        it('Should add assignment', async () => {
              const result =  await cert.addAssignment(emails[0], links[0], _status[0], fProject[1], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._link, links[0]);
        });

        it('Should update assignment status', async () => {
              const result =  await cert.updateAssignmentStatus(emails[0], _status[1], fProject[1], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._status, _status[1]);
        });


        it('Should change student email', async () => {
              const result =  await cert.changeStudentEmail(emails[0], emails[1], {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args._newEmail, emails[1]);
        });

        it('Should transfer Ownership', async () => {
             const result =  await cert.transferOwnership(nonOwner, {from: owner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args.newOwner,nonOwner);
        });

         it('Should Renounce Ownership', async () => {
             const result =  await cert.renounceOwnership({from: nonOwner});
                assert.equal(result.receipt.status, true);
                assert.equal(result.logs[0].args.newOwner,'0x0000000000000000000000000000000000000000');
        });

        async function shouldThrow(promise) {
try {
    await promise;
    assert(true);
}
catch (err) {
    return;
}
assert(false, "The contract did not throw.");

}

module.exports = {
    shouldThrow,
};

})
