using Godot;
using System;
using System.Collections.Generic;

public abstract class PackedState{
	private string m_State;
	private Node m_Actor;
	private Action<string> m_ChangeStateFn;
	protected Dictionary<string, object> m_Blackboard;

		public PackedState(string state, Node actor, Action<string> change_state_fn, Dictionary<string, object> blackboard){
			m_State = state;
			m_Actor = actor;
			m_ChangeStateFn = change_state_fn;
			m_Blackboard = blackboard;
		}

		public void ChangeState(string state){
			m_ChangeStateFn(state);
		}

		public Node GetActor(){
			return m_Actor;
		}

		public string GetState(){
			return m_State;
		}

		public abstract void StateFn();

		public abstract void InitWhenChangeStateFn();
	}