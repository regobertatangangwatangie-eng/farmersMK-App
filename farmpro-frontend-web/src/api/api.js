import axios from 'axios';

const rawApiBaseUrl = import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_GATEWAY_URL || 'http://localhost:8080';
const API_GATEWAY_URL = rawApiBaseUrl.replace(/\/$/, '');

if (import.meta.env.PROD && /localhost|127\.0\.0\.1|10\.0\.2\.2/.test(API_GATEWAY_URL)) {
  console.warn('VITE_API_BASE_URL points to a local address in production. Update it before release.');
}

const gatewayApi = axios.create({
  baseURL: API_GATEWAY_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

const getErrorMessage = (error, fallbackMessage) => {
  return error?.response?.data?.message || error?.message || fallbackMessage;
};

export const fetchProducts = async () => {
  try {
    const response = await gatewayApi.get('/products');
    return response.data;
  } catch (error) {
    console.error('Error fetching products:', error);
    return [];
  }
};

export const registerUser = async ({ name, email, role, password }) => {
  try {
    const response = await gatewayApi.post('/users/register', {
      name,
      email,
      role,
      password
    });
    return response.data;
  } catch (error) {
    throw new Error(getErrorMessage(error, 'Registration failed.'));
  }
};

export const loginUser = async ({ email, password }) => {
  try {
    const response = await gatewayApi.post('/users/login', { email, password });
    return response.data;
  } catch (error) {
    throw new Error(getErrorMessage(error, 'Login failed.'));
  }
};

export const fetchUsersAdmin = async (token) => {
  try {
    const response = await gatewayApi.get('/users', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    return Array.isArray(response.data) ? response.data : [];
  } catch (error) {
    throw new Error(getErrorMessage(error, 'Failed to fetch users.'));
  }
};