import Web3 from 'web3';
import Cert from '../build/contracts/Cert.json';

let web3;
let cert;

const initWeb3 = () => {
return new Promise((resolve, reject) => {
    if(typeof window.ethereum !== 'undefined') {
      const web3 = new Web3(window.ethereum);
      window.ethereum.enable()
        .then(() => {
          resolve(
            new Web3(window.ethereum)
          );
        })
        .catch(e => {
          reject(e);
        });
      return;
    }
    if(typeof window.web3 !== 'undefined') {
      return resolve(
        new Web3(window.web3.currentProvider)
      );
    }
    resolve(new Web3('http://localhost:9545'));
  });
}  

const initContract = () => {
  const deploymentKey = Object.keys(Cert.networks)[0];
  return new web3.eth.Contract(
    Cert.abi,
    Cert
      .networks[deploymentKey]
      .address
  );
};

const initApp = () => {
  const addAdmin = document.getElementById('addAdmin');
  const addResult = document.getElementById('add-result');
  const removeAdmin = document.getElementById('removeAdmin');
  const removeResult = document.getElementById('remove-result');
  const changeAdminLimit = document.getElementById('changeAdminLimit');
  const changeResult = document.getElementById('change-result');
  const transferOwnership = document.getElementById('transferOwnership');
  const transferResult = document.getElementById('transfer-result');
  const renounceOwnership = document.getElementById('renounceOwnership');
  const renounceResult = document.getElementById('renounce-result');
  const addStudent = document.getElementById('addStudent');
  const addStudentResult = document.getElementById('add-student-result');
  const removeStudent = document.getElementById('removeStudent');
  const removeStudentResult = document.getElementById('remove-student-result');
  const changeStudentName = document.getElementById('changeStudentName');
  const studentNameResult = document.getElementById('student-name-result');
  const changeStudentCommendation = document.getElementById('changeStudentCommendation');
  const studentCommendationResult = document.getElementById('student-commendation-result');
  const changeStudentEmail = document.getElementById('changeStudentEmail');
  const studentEmailResult = document.getElementById('student-email-result');
  const changeStudentGrade = document.getElementById('changeStudentGrade');
  const studentGradeResult = document.getElementById('student-grade-result');
  const addAssignment = document.getElementById('addAssignment');
  const addAssignmentResult = document.getElementById('add-assignment-result');
  const updateAssignmentStatus = document.getElementById('updateAssignmentStatus');
  const updateAssignmentResult = document.getElementById('update-assignment-result');
  const getAssignmentInfo = document.getElementById('getAssignmentInfo');
  const getAssignmentResult = document.getElementById('get-assignment-result');
  const maxAdmins = document.getElementById('maxAdmins');
  const maxResult = document.getElementById('max-result');
  const adminIndex = document.getElementById('adminIndex');
  const indexResult = document.getElementById('id-result');
  const studentIndex = document.getElementById('studentIndex');
  const stResult = document.getElementById('st-result');
  const isOwner = document.getElementById('isOwner');
  const isResult = document.getElementById('is-result');
  const ownerAddress = document.getElementById('ownerAddress');
  const ownerResult = document.getElementById('owner-result');
  const admins = document.getElementById('admins');
  const adminsResult = document.getElementById('admins-result');
  const adminsReverseMapping = document.getElementById('adminsReverseMapping');
  const minResult = document.getElementById('min-result');
  const students = document.getElementById('students');
  const stuResult = document.getElementById('stu-result'); 
  const ownBal = document.getElementById('ownBal');
  const ownResult = document.getElementById('own-result');
  const donateEth = document.getElementById('donateEth');
  const donResult = document.getElementById('don-result');
  const withdrawEth = document.getElementById('withdrawEth');
  const witResult = document.getElementById('wit-result');
  
  let accounts = [];

  web3.eth.getAccounts().then(_accounts => {
	accounts = _accounts;
	});

    addAdmin.addEventListener('submit', (e) => {
    e.preventDefault();
    const addr = e.target.elements[0].value;
    cert.methods.addAdmin(addr).send({from:accounts[0]})
    .then(result => {
      addResult.innerHTML = `New admin added successfully`;
    })
    .catch(_e => {
      addResult.innerHTML = `error....only accessible by Owner, ensure maxAdmin hasn't beenreach`;
    });
  });

  removeAdmin.addEventListener('submit', (e) => {
    e.preventDefault();
    const addr = e.target.elements[0].value;
    cert.methods.removeAdmin(addr).send({from: accounts[0]})
    .then(result => {
      removeResult.innerHTML = `admin removed`;
    })
    .catch(_e => {
      removeResult.innerHTML = `error....only accessible by Owner`;
    });
  });

  changeAdminLimit.addEventListener('submit', (e) => {
    e.preventDefault();
    const id = e.target.elements[0].value;
    cert.methods.changeAdminLimit(id).send({from: accounts[0]})
    .then(result => {
      changeResult.innerHTML = `admin limit changed`;
    })
    .catch(_e => {
      changeResult.innerHTML = `error...new limit is lesser than already added admins count}`;
    });
  });

  transferOwnership.addEventListener('submit', (e) => {
    e.preventDefault();
    const addr = e.target.elements[0].value;
    cert.methods.transferOwnership(addr).send({from: accounts[0]})
    .then(result => {
      transferResult.innerHTML = `Ownership transferred`;
    })
    .catch(_e => {
      transferResult.innerHTML = `error....only accessible by Owner, must have 2 admins present`;
    });
  });


renounceOwnership.addEventListener('submit', (e) => {
    e.preventDefault();
    const addr = e.target.elements[0].value;
    cert.methods.renounceOwnership().send({from: accounts[0]})
    .then(result => {
      renounceResult.innerHTML = `Ownership Renounced`;
    })
    .catch(_e => {
      renounceResult.innerHTML = `error....only accessible by Owner, must have 2 admins present`;
    });
  });

  addStudent.addEventListener('submit', (e) => {
    e.preventDefault();
    const fName = e.target.elements[0].value;
    const lName = e.target.elements[1].value;
    const commd = e.target.elements[2].value;
    const grade = e.target.elements[3].value;
    const email = e.target.elements[4].value;
    cert.methods.addStudent(fName, lName, commd, grade, email).send({from: accounts[0]})
    .then(result => {
      addStudentResult.innerHTML = `Student added`;
    })
    .catch(_e => {
      addStudentResult.innerHTML = `error....only accessible by Owner, existing email`;
    });
  });

  removeStudent.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    cert.methods.removeStudent(email).send({from: accounts[0]})
    .then(result => {
      removeStudentResult.innerHTML = `Student removed`;
    })
    .catch(_e => {
      removeStudentResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

  changeStudentName.addEventListener('submit', (e) => {
    e.preventDefault();
    const fName = e.target.elements[0].value;
    const lName = e.target.elements[1].value;
    const email = e.target.elements[2].value;
    cert.methods.changeStudentName(fName, lName, email).send({from: accounts[0]})
    .then(result => {
      studentNameResult.innerHTML = `Student name changed`;
    })
    .catch(_e => {
      studentNameResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

  changeStudentCommendation.addEventListener('submit', e => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    const commd = e.target.elements[1].value;
    cert.methods.changeStudentCommendation(email, commd).send({from: accounts})
    .then(result => {
      studentCommendationResult.innerHTML = `Student commendation changed`;
    })
    .catch(() => {
      studentCommendationResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

  changeStudentEmail.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    const newEmail = e.target.elements[1].value
    cert.methods.changeStudentEmail(email, newEmail).send({from: accounts[0]})
    .then(result => {
      studentEmailResult.innerHTML = `Student email changed`;
    })
    .catch(_e => {
      studentEmailResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

  changeStudentGrade.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    const grade = e.target.elements[1].value;
    cert.methods.changeStudentGrade(email, grade).send({from: accounts[0]})
    .then(result => {
      studentGradeResult.innerHTML = `Student grade changed`;
    })
    .catch(_e => {
      studentGradeResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

addAssignment.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    const link = e.target.elements[1].value;
    const status = e.target.elements[2].value;
    const fProject = e.target.elements[3].value;
    cert.methods.addAssignment(email, link, status, fProject).send({from: accounts[0]})
    .then(result => {
      addAssignmentResult.innerHTML = `Student assignment added`;
    })
    .catch(_e => {
      addAssignmentResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

updateAssignmentStatus.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    const status = e.target.elements[1].value;
    const fProject = e.target.elements[2].value;
    cert.methods.updateAssignmentStatus(email, status, fProject).send({from: accounts[0]})
    .then(result => {
      updateAssignmentResult.innerHTML = `Student assignment updated`;
    })
    .catch(_e => {
      updateAssignmentResult.innerHTML = `error....only accessible by Owner, email doesn't exist`;
    });
  });

	getAssignmentInfo.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
    const assId = e.target.elements[1].value;
        cert.methods.getAssignmentInfo(email, assId).call()
    .then(result => {
      stuResult.innerHTML = `admin Id: ${result[0]}
       ${result[1]}`;
    })
    .catch(_e => {
      stuResult.innerHTML = `error.....email doesn't exist, assignmentIndex not correct`;
    });
  });

	
	maxAdmins.addEventListener('submit', e => {
    e.preventDefault();
        cert.methods.maxAdmins().call()
    .then(result => {
      maxResult.innerHTML = `maxAdmins ${result[0]} `;
    })
    .catch(() => {
      maxResult.innerHTML = `error`;
    });
  });

	adminIndex.addEventListener('submit', e => {
    e.preventDefault();
	cert.methods.adminIndex().call()
    .then(result => {
      indexResult.innerHTML = `adminIndex ${result[0]} `;
    })
    .catch(() => {
      indexResult.innerHTML = `error`;
    });
  });

   
	studentIndex.addEventListener('submit', (e) => {
    e.preventDefault();
	cert.methods.studentIndex().call()
    .then(result => {
      stResult.innerHTML = `studentIndex ${result[0]} `;
    })
    .catch(_e => {
      stResult.innerHTML = `error`;
    });
  });

isOwner.addEventListener('submit', (e) => {
    e.preventDefault();
	cert.methods.isOwner().call()
    .then(result => {
      isResult.innerHTML = `true`;
    })
    .catch(_e => {
      isResult.innerHTML = `false`;
    });
  });

ownerAddress.addEventListener('submit', (e) => {
    e.preventDefault();
	cert.methods.owner().call()
    .then(result => {
      ownerResult.innerHTML = `${accounts[0]}`;
    })
    .catch(_e => {
      isResult.innerHTML = `error`;
    });
  });

admins.addEventListener('submit', (e) => {
    e.preventDefault();
    const acc = e.target.elements[0].value;
	cert.methods.admins(acc).call()
    .then(result => {
      adminsResult.innerHTML = `authorized ${result[0]} id ${result[1]} `;
    })
    .catch(_e => {
      adminsResult.innerHTML = `error`;
    });
  });

adminsReverseMapping.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = e.target.elements[0].value;
	cert.methods.adminsReverseMapping(email).call()
    .then(result => {
      minResult.innerHTML = `admin Id: ${accounts[0]} `;
    })
    .catch(_e => {
      minResult.innerHTML = `there was an error while trying to read user `;
    });
  });

students.addEventListener('submit', (e) => {
    e.preventDefault();
    const id = e.target.elements[0].value;
	cert.methods.students(id).call()
    .then(result => {
      stuResult.innerHTML = `student Id: ${result[0]}
       ${result[1]} ${result[2]} ${result[3]} ${result[4]}
       ${result[5]} ${result[6]}`;
    })
    .catch(_e => {
      stuResult.innerHTML = `there was an error while trying to read user`;
    });
  });


ownBal.addEventListener('submit', (e) => {
    e.preventDefault();
    const id = e.target.elements[0].value;
    web3.eth.getBalance(id, (err, bal) => {console.log(bal)});
});
	 
donateEth.addEventListener('submit', (e) => {
    e.preventDefault();
    const deploymentKey = Object.keys(Cert.networks)[0];
    const amount = e.target.elements[0].value;
    web3.eth.sendTransaction({from: accounts[0], to: Cert.networks[deploymentKey].address, value: web3.utils.toWei(amount, 'ether')})
  });

withdrawEth.addEventListener('submit', (e) => {
    e.preventDefault();

        cert.methods.withdrawEth().send({from: accounts[0]})
    .then(result => {
      minResult.innerHTML = `withdraw successful `;
    })
    .catch(_e => {
      minResult.innerHTML = `error`});
})
};

document.addEventListener('DOMContentLoaded', () => {
  initWeb3()
    .then(_web3 => {
      web3 = _web3;
      cert = initContract();
      initApp();
    })
    .catch(e => console.log(e.message));
});

