import React, { useState, useEffect } from 'react';
import { Modal, Button, Container, Form, FormGroup, Col, Row } from 'react-bootstrap';
import { PersonCircle } from 'react-bootstrap-icons';
const Profile = ({ user, userProfile }) => {
    const [fullName, setFullName] = useState('');
    const [isJournalist, setIsJournalist] = useState(false);
    const [employmentType, setEmploymentType] = useState('');
    const [organizationName, setOrganizationName] = useState('');

    const [showChangePasswordModal, setShowChangePasswordModal] = useState(false);
    const [showChangeEmailModal, setShowChangeEmailModal] = useState(false);
    const [passwordsMatch, setPasswordsMatch] = useState(true);
    const [passwordCriteriaMet, setPasswordCriteriaMet] = useState(false);
    const [passwordCriteriaError, setPasswordCriteriaError] = useState('');
    const [passwordMatchError, setPasswordMatchError] = useState('');
    const [newEmail, setNewEmail] = useState('');
    const [passwordData, setPasswordData] = useState({
        old_password: '',
        new_password: '',
        confirmation_password: '',
      });

    // Update state when userProfile prop changes
    useEffect(() => {
        if (userProfile) {
            setFullName(userProfile.full_name);
            setIsJournalist(userProfile.is_journalist);
            setEmploymentType(userProfile.type_of_employment);
            setOrganizationName(userProfile.organization_name);
        }
    }, [userProfile]);

    const handleFullNameChange = (e) => {
        setFullName(e.target.value);

    };

    const handleIsJournalistChange = () => {
        setIsJournalist((prevValue) => !prevValue);
        setEmploymentType(null)
        setOrganizationName(null);
    };

    /*
    const handleIsJournalistChange = (e) => {
        setIsJournalist(e.target.checked);

    };
    */
    const handleEmploymentTypeChange = (e) => {
        setEmploymentType(e.target.value);

    };
    
    const handleOrganizationNameChange = (e) => {
        setOrganizationName(e.target.value);

    };

    const handleOldPasswordChange = (e) => {
        const old_pass = e.target.value;
        setPasswordData({ ...old_pass, old_password: old_pass});
    }

    const handlePasswordChange = (e) => {
        const new_pass = e.target.value;
        console.log(new_pass);
        setPasswordData({ ...passwordData, new_password: new_pass });

        validatePasswordCriteria(new_pass); // Validate password criteria immediately upon change
        // Optionally, validate match only if the confirmation password has been entered
        if (passwordData.confirmation_password) {
          validatePasswordsMatch(new_pass, passwordData.confirmation_password);
        }
      };
      
    
      const handleConfirmationPasswordChange = (e) => {
        const newConfirmationPass = e.target.value;
        // Update the state with the new confirmation password
        setPasswordData({ ...passwordData, confirmation_password: newConfirmationPass });

        // Use the most current password directly from formData and the new confirmation password for comparison
        // This ensures you're always using the latest values for both fields
        validatePasswordsMatch(passwordData.new_password, newConfirmationPass);
      };
    
      const validatePasswordCriteria = (e) => {
        const password = passwordData.new_password
        const minLengthRegex = /.{7,}/; // Checks for at least 8 characters
        const upperCaseRegex = /[A-Z]/; // Checks for at least one uppercase letter
        const lowerCaseRegex = /[a-z]/; // Checks for at least one lowercase letter
        const numberRegex = /[0-9]/; // Checks for at least one digit
        const specialCharRegex = /[^A-Za-z0-9]/; // Checks for at least one special character
      
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
        setPasswordsMatch(passwordsAreMatching);
      
        const errorMessage = passwordsAreMatching ? '' : 'Passwords do not match.';
        setPasswordMatchError(errorMessage);
      };
    

    const handlePasswordUpdate = async () => {
        const token = localStorage.getItem('token').toString(); 
        try {
            const response = await fetch('http://127.0.0.1:8000/account/change-password/', {
                method: 'PUT', // or 'PATCH' depending on your backend
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({ 
                    old_password: passwordData.old_password,
                    new_password: passwordData.new_password, 
                }),
            });
    
            if (response.ok) {

                setShowChangeEmailModal(false); 
                window.location.reload();
            } else {
                console.error('Failed to update password');
                // Handle error (e.g., show an error message)
            }
        } catch (error) {
            console.error('Error updating password:', error);
        }
    };

    const handleEmailUpdate = async () => {
        const token = localStorage.getItem('token').toString(); 
        try {
            const response = await fetch('http://127.0.0.1:8000/account/update-email/', {
                method: 'PUT', // or 'PATCH' depending on your backend
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({ email: newEmail }),
            });
    
            if (response.ok) {
                console.log('Email updated successfully');
                setShowChangeEmailModal(false); 
                window.location.reload();
            } else {
                console.error('Failed to update email');
                // Handle error (e.g., show an error message)
            }
        } catch (error) {
            console.error('Error updating email:', error);
        }
    };

    const handleSubmit = async (e) => {
        
        e.preventDefault();
        try {
            const token = localStorage.getItem('token').toString(); 
            
            // Make API call to update profile
            const response = await fetch('http://127.0.0.1:8000/account/update-profile/', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
                // Add any authentication headers if needed
            },
            body: JSON.stringify({
                full_name: fullName,
                is_journalist: isJournalist,
                type_of_employment: employmentType,
                organization_name: organizationName,
            }),
            });
            if (response.ok) {
            // Handle success
            console.log('Profile updated successfully');
            window.location.reload();
            } else {
            // Handle error
            console.error('Failed to update profile');
            }
        } catch (error) {
            console.error('Error updating profile:', error.message);
        }
        };
  return (
    <>
    <Container fluid id="profile-container">
                <Row>
                    <PersonCircle id="profile-person-icon"/>
                </Row>
                <Row>
                    <Form onSubmit={handleSubmit}>
                        <Row>
                            <Col>
                                <Form.Group>
                                    <Form.Label>Email address</Form.Label>
                                    <Form.Control id="email" type="email" placeholder={user.email} disabled/>
                                   
                                </Form.Group>
                            </Col>
                        </Row>
                        <Row>
                            <Col>
                                <Form.Group>
                                    <Form.Label>Full name</Form.Label>
                                    <Form.Control id="fullName" type="text" placeholder={fullName} onChange={handleFullNameChange}/>
                                   
                                </Form.Group>
                            </Col>
                            <Col>
                                <Form.Group controlId="ProfileIsJournalist">
                                    <Form.Label className="mb-2">Are you a journalist?</Form.Label>
                                    <Row>
                                        <Col id="ProfileIsJournalistCol1">
                                            <Form.Check type="checkbox" label="Yes" checked={isJournalist === true}  onChange={handleIsJournalistChange}/>
                                        </Col>
                                        <Col id="ProfileIsJournalistCol2">
                                            <Form.Check type="checkbox" label="No" checked={isJournalist === false} onChange={handleIsJournalistChange}/>
                                        </Col>
                                    </Row>
                                </Form.Group>
                            </Col>
                        </Row>

                        {isJournalist && (
                        <Row>
                        
                            <Col>
                                <Form.Group className="mb-3">
                                    <Form.Label className="mb-1"> freelance or employed in the private/public sector?</Form.Label>
                                    <Form.Select id="employmentType" className="custom-select" value={employmentType || "freelance"} onChange={handleEmploymentTypeChange}>
                                        <option value="freelance">freelance</option>
                                        <option value="employed">employed in the private/public sector</option>
                                    </Form.Select>
                                </Form.Group>
                            </Col>
                            <Col>
                                {employmentType === 'employed' && isJournalist && (
                                <FormGroup >
                                    <Form.Label className="mb-1">Name of organization</Form.Label>
                                    <Form.Control id="organizationName" type="text" placeholder= {organizationName} onChange={handleOrganizationNameChange}/>
                                </FormGroup>
                                )}
                            </Col>
                        
                        </Row>
                        )}
                        <Button id="update-profile-btn" type="submit">Update Profile</Button>
                    </Form>
                </Row>
                <Row id="extra-options-profile-row">
                    <Col>
                        <Button id="update-email-btn" onClick={() => setShowChangeEmailModal(true)}>Change email</Button>
                    </Col>
                    <Col>
                        <Button id="update-pwd-btn" onClick={() => setShowChangePasswordModal(true)}>Change password</Button>
                    </Col>
                </Row>
                <Modal id="modal-change-email" show={showChangeEmailModal} onHide={() => setShowChangeEmailModal(false)} centered>
                    <Modal.Header id="modal-change-email-header">
                        <Modal.Title>Change Email</Modal.Title>
                    </Modal.Header>
                    <Modal.Body id="modal-change-email-body">
                        <Form.Group>
                            <Form.Control id="email" type="email" placeholder="new email address" onChange={(e) => setNewEmail(e.target.value)}/>                          
                        </Form.Group>
                    </Modal.Body>
                    <Modal.Footer id="modal-change-footer">
                        <Container fluid>
                            <Row>
                                <Col>
                                <Button id="previous-button"  onClick={() => setShowChangeEmailModal(false)}>Close</Button>   
                                </Col>
                                <Col>
                                <Button id="next-button" onClick={handleEmailUpdate}>Update</Button> 
                                </Col>
                            </Row>
                        </Container>
                                    
                        
                    </Modal.Footer>
                </Modal>

                {/* Change Password Modal */}
                <Modal show={showChangePasswordModal} onHide={() => setShowChangePasswordModal(false)} centered>
                    <Modal.Header>
                        <Modal.Title>Change Password</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                        <Row>
                            <Form.Group id="login-form-group" >
                                <Form.Control 
                                    id="login-form-control-pass" 
                                    type="password" 
                                    placeholder="Old password" 
                                    onChange={handleOldPasswordChange}
                                />
                            </Form.Group>
                        </Row>
                        <Row>
                            <Form.Group id="login-form-group" >
                                <Form.Control 
                                    id="login-form-control-pass" 
                                    type="password" 
                                    placeholder="New password" 
                                    onChange={handlePasswordChange}
                                    isInvalid={!!passwordCriteriaError}
        
                                />
                                <Form.Control.Feedback type="invalid">
                                    {passwordCriteriaError}
                                </Form.Control.Feedback>
                            </Form.Group>
                        </Row>
                        <Row>
                            <Form.Group id="login-form-group" >
                                <Form.Control 
                                    id="login-form-control-pass" 
                                    type="password" 
                                    placeholder="Retype password" 
                                    onChange={handleConfirmationPasswordChange}
                                    isInvalid={!!passwordMatchError}
                                />
                                <Form.Control.Feedback type="invalid">
                                    {passwordMatchError}
                                </Form.Control.Feedback>
                            </Form.Group>
                        </Row>
                    </Modal.Body>
                    <Modal.Footer>
                        <Container fluid>
                            <Row>
                                <Col>
                                    <Button id="previous-button" onClick={() => setShowChangePasswordModal(false)}>Close</Button>
                                </Col>
                                <Col>
                                    <Button id="next-button" onClick={handlePasswordUpdate} disabled={!passwordCriteriaMet || !passwordsMatch}>Update</Button>
                                </Col>
                            </Row>
                        </Container>
                    </Modal.Footer>
                </Modal>
    </Container>
    </>
  );
};

export default Profile;
