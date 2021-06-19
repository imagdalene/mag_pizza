export enum PizzaCrumbActions {
  "SET_CRUMB" = "SET_CRUMB"
}

export interface PizzaCrumb {
  link: string;
  locationLabel: string;
}

const initialState:PizzaCrumb[] = [{
  link: '/',
  locationLabel: 'Home'
}]

export const SetPizzaCrumbAction = (payload: PizzaCrumb[]) => {
  return { 
    action: PizzaCrumbActions.SET_CRUMB,
    payload
  }
}

export const PizzaCrumbReducer = function(state = initialState, action: { type: string; payload: PizzaCrumb[]}) {
  switch(action.type) {
    case PizzaCrumbActions.SET_CRUMB:
      return [...initialState, action.payload]
    default:
      return state
  }
}