import axios from 'axios';

const API = axios.create({
  baseURL: 'http://10.0.2.2:8082', // Android emulator
  // baseURL: 'http://localhost:8082' // Web
});

export const getProducts = () => API.get('/products');
export const addProduct = (product) => API.post('/products', product);