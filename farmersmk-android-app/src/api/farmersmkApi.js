import { apiClient, readApiError, withBearer } from './client';

export const FarmersMKApi = {
  async register({ name, email, role, password }) {
    try {
      const response = await apiClient.post('/users/register', { name, email, role, password });
      return response.data;
    } catch (error) {
      throw new Error(readApiError(error, 'Registration failed.'));
    }
  },

  async login({ email, password }) {
    try {
      const response = await apiClient.post('/users/login', { email, password });
      return response.data;
    } catch (error) {
      throw new Error(readApiError(error, 'Login failed.'));
    }
  },

  async getProducts() {
    try {
      const response = await apiClient.get('/products');
      return Array.isArray(response.data) ? response.data : [];
    } catch (error) {
      throw new Error(readApiError(error, 'Unable to load products.'));
    }
  },

  async getNotifications() {
    try {
      const response = await apiClient.get('/api/notifications');
      return Array.isArray(response.data) ? response.data : [];
    } catch (error) {
      throw new Error(readApiError(error, 'Unable to load notifications.'));
    }
  },

  async getProtectedUsers(token) {
    try {
      const response = await apiClient.get('/users', withBearer(token));
      return Array.isArray(response.data) ? response.data : [];
    } catch (error) {
      throw new Error(readApiError(error, 'Unable to load users.'));
    }
  },

  async checkRealtime() {
    try {
      const response = await apiClient.get('/ws');
      return response.data;
    } catch (error) {
      throw new Error(readApiError(error, 'Realtime check failed.'));
    }
  }
};
