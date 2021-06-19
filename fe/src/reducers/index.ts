import { createStore, combineReducers } from 'redux'
import { composeWithDevTools } from 'redux-devtools-extension';

import { PizzaCrumbReducer } from './breadcrumbs'

const rootReducer = combineReducers({
  pizzaCrumbs: PizzaCrumbReducer
})

const store = createStore(rootReducer, composeWithDevTools())

export type RootState = ReturnType<typeof rootReducer>

export default store