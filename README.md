# EasyLib API Service

A JavaScript library to interact with Laravel backend API for authentication.

## Installation

```bash
npm install easylibapi
```

## Usage

### Authentication

```javascript
import { AuthService } from "easylibapi";

// Register a new user
const registerUser = async () => {
  try {
    const userData = {
      name: "John Doe",
      gender: "male",
      address: "123 Main St",
      email: "john@example.com",
      phone_number: "1234567890",
      date_of_birth: "1990-01-01",
      password: "password123",
      password_confirmation: "password123",
    };

    const response = await AuthService.register(userData);
    console.log("Registration successful:", response);
  } catch (error) {
    console.error("Registration failed:", error);
  }
};

// Login
const loginUser = async () => {
  try {
    const response = await AuthService.login({
      email: "john@example.com",
      password: "password123",
    });
    console.log("Login successful:", response);
  } catch (error) {
    console.error("Login failed:", error);
  }
};

// Logout
const logoutUser = async () => {
  try {
    const response = await AuthService.logout();
    console.log("Logout successful:", response);
  } catch (error) {
    console.error("Logout failed:", error);
  }
};

// Check if user is authenticated
const checkAuthStatus = () => {
  const isAuthenticated = AuthService.isAuthenticated();
  console.log("Is authenticated:", isAuthenticated);
};

// Get current user data
const getCurrentUser = () => {
  const user = AuthService.getCurrentUser();
  console.log("Current user:", user);
};
```

### Customizing API URL

You can modify the API URL by changing the configuration:

```javascript
import { API_CONFIG } from "easylibapi";

// Update API base URL if needed
API_CONFIG.BASE_URL = "https://your-api-domain.com/api";
```

````
<copilot-edited-file>```markdown
# EasyLib API Service

A JavaScript library to interact with Laravel backend API for authentication.

## Installation

```bash
npm install easylibapi
````

## Usage

### Authentication

```javascript
import { AuthService } from "easylibapi";

// Register a new user
const registerUser = async () => {
  try {
    const userData = {
      name: "John Doe",
      gender: "male",
      address: "123 Main St",
      email: "john@example.com",
      phone_number: "1234567890",
      date_of_birth: "1990-01-01",
      password: "password123",
      password_confirmation: "password123",
    };

    const response = await AuthService.register(userData);
    console.log("Registration successful:", response);
  } catch (error) {
    console.error("Registration failed:", error);
  }
};

// Login
const loginUser = async () => {
  try {
    const response = await AuthService.login({
      email: "john@example.com",
      password: "password123",
    });
    console.log("Login successful:", response);
  } catch (error) {
    console.error("Login failed:", error);
  }
};

// Logout
const logoutUser = async () => {
  try {
    const response = await AuthService.logout();
    console.log("Logout successful:", response);
  } catch (error) {
    console.error("Logout failed:", error);
  }
};

// Check if user is authenticated
const checkAuthStatus = () => {
  const isAuthenticated = AuthService.isAuthenticated();
  console.log("Is authenticated:", isAuthenticated);
};

// Get current user data
const getCurrentUser = () => {
  const user = AuthService.getCurrentUser();
  console.log("Current user:", user);
};
```

### Customizing API URL

You can modify the API URL by changing the configuration:

```javascript
import { API_CONFIG } from "easylibapi";

// Update API base URL if needed
API_CONFIG.BASE_URL = "https://your-api-domain.com/api";
```
