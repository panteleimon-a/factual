import React, { useState } from 'react';
import { Navbar, Nav, Modal, Button, Container, Form } from 'react-bootstrap';
import { PersonCircle } from 'react-bootstrap-icons';

const CustomNavbar = () => {

    const [showLoginModal, setShowLoginModal] = useState(false);
    const [showRegisterModal, setShowRegisterModal] = useState(false);

    const handleLoginModalShow = () => setShowLoginModal(true);
    const handleLoginFromRegisterModalShow = () => {
        handleRegisterModalClose() 
        setShowLoginModal(true);
    }

    const handleLoginModalClose = () => setShowLoginModal(false);
    const handleRegisterModalShow = () => {
        handleLoginModalClose() 
        setShowRegisterModal(true)
    };

    const handleRegisterModalClose = () => setShowRegisterModal(false);

    const handleLogin = () => {
        // Handle the login logic here

        // Close the login modal after login
        handleLoginModalClose();
      };
    
    const handleRegister = () => {
        // Handle the registration logic here

        // Close the register modal after registration
        handleRegisterModalClose();
     };

    return (  
        <>
            <Navbar static="top" >
                <Container fluid id="navbar-container">
                    <Navbar.Brand id="navbar-brand" href="/#home">factual</Navbar.Brand>

                    <Nav className="justify-content-end">
                    <Nav.Link id="nav-link"  onClick={handleLoginModalShow}>
                        <PersonCircle id="person-icon" />
                    </Nav.Link>
                    </Nav>
                </Container>
            </Navbar>
            <Modal show={showLoginModal} onHide={handleLoginModalClose}>
                <Modal.Header>
                    <Modal.Title id="modal-title">Login</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Form>
                        <Form.Group id="login-form-group" controlId="formUsername">
                        <Form.Label id="login-form-label">Username</Form.Label>
                        <Form.Control id="login-form-control" type="text" placeholder="Email" />
                        </Form.Group>
                        <Form.Group id="login-form-group" controlId="formPassword">
                        <Form.Label id="login-form-label">Password</Form.Label>
                        <Form.Control id="login-form-control" type="password" placeholder="Enter your password" />
                        </Form.Group>
                    </Form>
                </Modal.Body>
                <Modal.Footer>
                    <Button id="login-button" variant="secondary">
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
                    <p>Registration Form Goes Here</p>
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" id="login-button">
                        Register
                    </Button>
                    <Button variant="secondary" id="register-button" onClick={handleLoginFromRegisterModalShow}>
                        Login
                    </Button>
                </Modal.Footer>
            </Modal>
        </>    
    );
}
 
export default CustomNavbar;