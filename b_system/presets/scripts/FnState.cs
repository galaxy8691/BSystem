using Godot;
using System;
using System.Collections.Generic;
public class FnState : PackedState{
	private Action m_Fn;
	private Action m_InitWhenChangeStateFn;

	public FnState(string state, Node actor, Action<string> change_state_fn, Dictionary<string, object> blackboard, Action fn, Action init_when_change_state_fn) : base(state, actor, change_state_fn, blackboard){
		m_Fn = fn;
		m_InitWhenChangeStateFn = init_when_change_state_fn;
	}

	public override void StateFn(){
		m_Fn();
	}

	public override void InitWhenChangeStateFn(){
		m_InitWhenChangeStateFn();
	}
}
