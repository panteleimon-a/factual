import React, { useState } from 'react';
import { Navbar, Nav, Modal, Button, Container, Form, FormGroup, Col, Row, Dropdown } from 'react-bootstrap';
import { PersonCircle } from 'react-bootstrap-icons';

const CustomNavbar = ({isLoggedIn, setIsLoggedIn, handleLogout }) => {
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [showRegisterModal, setShowRegisterModal] = useState(false);

  const handleLoginModalClose = () => setShowLoginModal(false);
  const handleRegisterModalClose = () => setShowRegisterModal(false);


  const [showNotActiveModal, setNotActiveModal] = useState(false);
  const handleNotActiveModalShowClose = () => setNotActiveModal(false);

  const [registerStep, setRegisterStep] = useState(1);
  const handleRegisterStepNext = () => {
    if (registerStep === 1) {

      validateEmail(formData.email); 
      validatePasswordCriteria(formData.password);
      validatePasswordsMatch();
  

      if (emailValidation && passwordCriteriaMet && passwordsMatch) {
        setRegisterStep(registerStep + 1);
      }
    } else {

      setRegisterStep(registerStep + 1);
    }
  };

  const [isJournalist, setIsJournalist] = useState(null);
  const [employmentTypeField, setEmploymentTypelField] = useState('');
  const [organizationNameField, setOrganizationNameField] = useState('');

  const [passError, setPassError] = useState(false);
  const [isActive, setIsActive] = useState(true);
  const [passwordsMatch, setPasswordsMatch] = useState(true);
  const [passwordCriteriaMet, setPasswordCriteriaMet] = useState(false);
  const [passwordCriteriaError, setPasswordCriteriaError] = useState('');
  const [passwordMatchError, setPasswordMatchError] = useState('');
  const [emailValidation, setEmailValidation] = useState(true);
  const [emailError, setEmailError] = useState('');

  const validateEmail = () => {
    const email = formData.email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const isValidEmail = emailRegex.test(email);
    setEmailValidation(isValidEmail);
  
    if (!isValidEmail) {
      setEmailError('Please enter a valid email address.');
    } else {
      setEmailError('');
    }
  };

  const handleEmailChange = (e) => {
    const { value } = e.target;
    setFormData({ ...formData, email: value });
    validateEmail(value);
  };
  

  const handlePasswordChange = (e) => {
    const newPass = e.target.value;
    setFormData({ ...formData, password: newPass });
    validatePasswordCriteria(newPass); 
    if (formData.confirmation_password) {
      validatePasswordsMatch(newPass, formData.confirmation_password);
    }
  };
  

  const handleConfirmationPasswordChange = (e) => {
    const newConfirmationPass = e.target.value;

    setFormData({ ...formData, confirmation_password: newConfirmationPass });
    console.log("hi", newConfirmationPass)

    validatePasswordsMatch(formData.password, newConfirmationPass);
  };

  const validatePasswordCriteria = (e) => {
    const password = formData.password
    const minLengthRegex = /.{7,}/;
    const upperCaseRegex = /[A-Z]/;
    const lowerCaseRegex = /[a-z]/;
    const numberRegex = /[0-9]/;
    const specialCharRegex = /[^A-Za-z0-9]/;
    const isValidLength = minLengthRegex.test(password);
    const hasUpperCase = upperCaseRegex.test(password);
    const hasLowerCase = lowerCaseRegex.test(password);
    const hasNumber = numberRegex.test(password);
    const hasSpecialChar = specialCharRegex.test(password);
  
    const isValid = isValidLength && hasUpperCase && hasLowerCase && hasNumber && hasSpecialChar;
    setPasswordCriteriaMet(isValid);
    setPasswordCriteriaError(isValid ? '' : 'Password must meet all criteria: at least 8 characters, including one uppercase letter, one lowercase letter, one number, and one special symbol.');
  };
  
  const validatePasswordsMatch = (password, confirmationPassword) => {
    const passwordsAreMatching = password === confirmationPassword;
    console.log(password);
    console.log(confirmationPassword);
    console.log(passwordsAreMatching);
    setPasswordsMatch(passwordsAreMatching);
  
    const errorMessage = passwordsAreMatching ? '' : 'Passwords do not match.';
    setPasswordMatchError(errorMessage);
  };

  const handleCheckboxChange = () => {
    setIsJournalist((prevValue) => !prevValue);
  };

  const handleSelectChange = (e) => {
    setEmploymentTypelField(e.target.value);
  };

  const handleOrganizationNameFieldChange = (e) => {
    setOrganizationNameField(e.target.value);
  };

  const handleLoginModalShow = () => setShowLoginModal(true);

  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmation_password: '',
  });

  const handleRegisterModalShow = () => {
    handleLoginModalClose();
    setShowRegisterModal(true);
  };

  const handleNotActiveModalShow = () => {
    setNotActiveModal(true);
  }


  const handleLogin = async () => {
    

    const username = document.getElementById('login-form-control').value;
    const password = document.getElementById('login-form-control-pass').value;
    
    try {
      const response = await fetch('http://127.0.0.1:8000/account/login/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            'username': username,
            'password': password,
          }),
       
      });
      console.log(response)
      if (response.ok) {

        const tokenData = await response.json();
        const accessToken = tokenData.access;
        const refreshToken = tokenData.refresh;
        localStorage.setItem('token', accessToken);
        localStorage.setItem('refresh_token', refreshToken);
        setIsLoggedIn(true);
        handleLoginModalClose();
        window.location.reload();
      } else {
        const errorData = await response.json();
        const errorMessage = errorData.username || errorData.user_active_status || errorData.password || 'Login failed.';
        
        if (errorMessage[0] === "Invalid email"){
          setEmailError(true)
    
        }
        if (errorMessage[0] === 'Not active.'){
          setIsActive(false)
          console.log(isActive)
          handleLoginModalClose();
          handleNotActiveModalShow();
        }
        if (errorMessage[0] === 'Invalid password'){
          setPassError(true)
        }
      }
    } catch (error) {
      // Handle network errors or other issues
      console.error('Login failed:', error.message);
    }
  };

  const handleRegister = async () => {
 


    const { email, password } = formData;

    

    const fullName = document.getElementById('fullName').value;
 

    const isJournalist = document.getElementById('formRegisterIsJournalist').checked;


    const employmentTypeField = isJournalist ? document.getElementById('employmentType').value : null;


    const organizationNameField = (isJournalist && employmentTypeField === 'employed') ? document.getElementById('organizationName').value : null;


    try {
      const response = await fetch('http://127.0.0.1:8000/account/register/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
 
        },
        body: JSON.stringify({
          email: email,
          password: password,
          full_name: fullName,
          is_journalist: isJournalist,
          type_of_employment: employmentTypeField,
          organization_name: organizationNameField,
        }),
      });

      if (response.ok) {
 
        console.log('Registration successful');
        handleRegisterModalClose();
      } else {

        console.error('Registration failed:', response.statusText);
      }
    } catch (error) {
 
      console.error('Registration failed:', error.message);
    }
  };





  return (
    <>
      <Navbar fixed="top">
        <Container fluid id="navbar-container">
          <Navbar.Brand id="navbar-brand" href="/#home">
            factual
          </Navbar.Brand>
          <Nav className="justify-content-end">
            {isLoggedIn === false ? (
              <Nav.Link id="nav-link" onClick={handleLoginModalShow}>
                <PersonCircle id="person-icon" />
              </Nav.Link>
            ) : (
              <Dropdown id="nav-link-dropdown">
                <Dropdown.Toggle variant="link" id="dropdown-basic">
                  <PersonCircle id="person-icon" />
                </Dropdown.Toggle>
                <Dropdown.Menu>
                  <Dropdown.Item  href="/profile">Profile</Dropdown.Item>
                  <Dropdown.Item onClick={handleLogout}>Logout</Dropdown.Item>
                </Dropdown.Menu>
              </Dropdown>
            )}
          </Nav>
        </Container>
      </Navbar>
      <Modal show={showLoginModal} onHide={handleLoginModalClose}>
        <Modal.Header>
          <Modal.Title id="modal-title">Login</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form>
            <Form.Group id="login-form-group">
              <Form.Label id="login-form-label">Email</Form.Label>
              <Form.Control id="login-form-control" type="email" placeholder="Email" isInvalid={emailError}/>        
            </Form.Group>
            <Form.Group id="login-form-group">
              <Form.Label id="login-form-label">Password</Form.Label>
              <Form.Control id="login-form-control-pass" type="password" placeholder="Enter your password" isInvalid={passError}/>
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button id="login-button" variant="secondary" onClick={handleLogin}>
            Login
          </Button>
          <Button id="register-button" variant="secondary" onClick={handleRegisterModalShow}>
            Register
          </Button>
        </Modal.Footer>
      </Modal>
  
      <Modal show={showRegisterModal} onHide={handleRegisterModalClose}>
        <Modal.Header>
          <Modal.Title>Register</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {registerStep === 1 && (
            <Form>
              <Form.Group  className="mb-3">
                <Form.Label className="mb-1">email</Form.Label>
                <Form.Control 
                  id="email" 
                  type="email" 
                  placeholder="Enter your email" 
                  onChange={handleEmailChange}
                  isInvalid={!!emailError}
                  name="email" 
                  value={formData.email} 
                />
                <Form.Control.Feedback type="invalid">
                  {emailError}
                </Form.Control.Feedback>
              </Form.Group>
              <Form.Group className="mb-3">
                <Form.Label className="mb-1">Password</Form.Label>
                <Form.Control 
                  id="password"
                  type="password" 
                  placeholder="Enter your password" 
                  onChange={handlePasswordChange}
                  isInvalid={!!passwordCriteriaError}
                  name="password" 
                  value={formData.password} 
                />
                <Form.Control.Feedback type="invalid">
                  {passwordCriteriaError}
                </Form.Control.Feedback>
              </Form.Group>
              <Form.Group className="mb-3">
                <Form.Label>Confirm Password</Form.Label>
                <Form.Control
                  id="password_confirmation"
                  type="password"
                  placeholder="Confirm your password"
                  onChange={handleConfirmationPasswordChange}
                  isInvalid={!!passwordMatchError}
                  value={formData.confirmation_password}
                />
                <Form.Control.Feedback type="invalid">
                  {passwordMatchError}
                </Form.Control.Feedback>
              </Form.Group>
            </Form>
          )}
          {registerStep === 2 && (
            <Form>
              <Form.Group  className="mb-3">
                <Form.Label className="mb-1">Full Name</Form.Label>
                <Form.Control id="fullName" type="text" placeholder="Enter your full name" />
              </Form.Group>
              <Form.Group controlId="formRegisterIsJournalist" className="mb-3">
                <Form.Label className="mb-2">Are you a journalist?</Form.Label>
                <Row>
                  <Col>
                    <Form.Check type="checkbox" label="Yes" checked={isJournalist === true} onChange={handleCheckboxChange} />
                  </Col>
                  <Col>
                    <Form.Check type="checkbox" label="No" checked={isJournalist === false} onChange={handleCheckboxChange} />
                  </Col>
                </Row>
              </Form.Group>
              {isJournalist && (
                <Form.Group controlId="employmentTypeField" className="mb-3">
                  <Form.Label className="mb-1"> freelance or employed in the private/public sector?</Form.Label>
                  <Form.Select id="employmentType" value={employmentTypeField} onChange={handleSelectChange} className="custom-select">
                    <option value="freelance">freelance</option>
                    <option value="employed">employed in the private/public sector</option>
                  </Form.Select>
                </Form.Group>
              )}
              {employmentTypeField === 'employed' && isJournalist && (
                <FormGroup controlId="organizationNameField">
                  <Form.Label className="mb-1">Name of organization</Form.Label>
                  <Form.Control id="organizationName" type="text" placeholder="Name of organization" value={organizationNameField} onChange={handleOrganizationNameFieldChange} />
                </FormGroup>
              )}
            </Form>
          )}
        </Modal.Body>
        <Modal.Footer>
          {registerStep === 1 && (
            <Form>
              <Button variant="secondary" id="next-button" onClick={handleRegisterStepNext}>
                Next
              </Button>
            </Form>
          )}
          {registerStep === 2 && (
            <Container fluid>
              <Form>
                <Row xs={12}>
                  <Col xs={6}>
                    <Button variant="secondary" id="previous-button" onClick={() => setRegisterStep(1)}>
                      Previous
                    </Button>
                  </Col>
                  <Col xs={6}>
                    <Button variant="secondary" id="register-button" onClick={handleRegister}>
                      Register
                    </Button>
                  </Col>
                </Row>
              </Form>
            </Container>
          )}
        </Modal.Footer>
      </Modal>
      <Modal show={showNotActiveModal} onHide={handleNotActiveModalShowClose} >
        <Modal.Header closeButton>
        </Modal.Header>
        <Modal.Body>
          <p>
            You are already registered on our site.<br></br>Your account activation is currently under review.
          </p>
        </Modal.Body>
      </Modal>
    </>
  );
  
};

export default CustomNavbar;
