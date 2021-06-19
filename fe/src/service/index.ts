import axios, { AxiosError, AxiosInstance, AxiosResponse } from "axios";

const baseURL = process.env.REACT_APP_baseURL

interface AuthResponse {
  accessToken: string
}

class ApiService {
  service = axios.create({
    baseURL
  })
  
  upgrade(accessToken: string) {
    this.service = axios.create({
      baseURL, 
      headers: {
        Authorization: `Bearer ${accessToken}`
      }
    })
  }

  getService():AxiosInstance {
    return this.service
  }
}

export const apiSvc = new ApiService()

export async function authenticate( email: string, password: string):Promise<AxiosResponse<AuthResponse>> {
  const ax = apiSvc.getService()
  return await ax.post('/login', { email, password}).then((value: AxiosResponse) => {
    const { data } = value
    apiSvc.upgrade(data.accessToken)
    return value
  })
}