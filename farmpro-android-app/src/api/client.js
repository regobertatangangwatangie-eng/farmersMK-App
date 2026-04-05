import axios from 'axios';
import { APP_CONFIG } from '../config/appConfig';

export const apiClient = axios.create({
  baseURL: APP_CONFIG.baseUrl,
  timeout: 12000,
  headers: {
    'Content-Type': 'application/json'
  }
});

export const withBearer = (token) => ({
  headers: {
    Authorization: `Bearer ${token}`
  }
});

export const readApiError = (error, fallbackMessage) => {
  return error?.response?.data?.message || error?.message || fallbackMessage;
};
