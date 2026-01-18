import React, { useState } from 'react';
import { Modal, Button, Form } from 'react-bootstrap';

const Login = ({isLoggedIn, setIsLoggedIn, handleLogout, showLoginModal, setShowLoginModal }) => {
  
  const handleLoginModalClose = () => setShowLoginModal(false);
  const [isActive, setIsActive] = useState(true);
  const [emailError, setEmailError] = useState('');
  const [passError, setPassError] = useState(false);

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

  return (
    <>
        <Modal show={showLoginModal} onHide={() => setShowLoginModal(false)}>
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
            <Button id="register-button" variant="secondary" >
                Register
            </Button>
            </Modal.Footer>
      </Modal>
    </>
  );
};

export default Login;
