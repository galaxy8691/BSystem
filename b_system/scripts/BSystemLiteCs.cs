using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class BSystemLiteCs : Node
{
	[Export]
	public bool DisabledOnMpMode = false;

	public enum ThreeStateBool{
	TRUE = 0,
	FALSE = 1,
	NOTSET = 2
	}
	private Dictionary<string, Action> m_StateFns = new Dictionary<string, Action>();
	private Dictionary<string, Action> m_InitWhenChangeStateFns = new Dictionary<string, Action>();
	private Dictionary<string, object> m_Blackboard = new Dictionary<string, object>();

	[Export]
	public Node Actor { get; set; }

	[Export]
	public string InitState { get; set; }

	public override void _Ready()
	{
		if (DisabledOnMpMode && !IsMultiplayerAuthority()){
			SetPhysicsProcess(false);
			return;
		}
		InitCall();
		ChangeState(InitState);
	}

	public void InsertState(string state, Action fn, Action init_fn)
	{
		m_StateFns[state] = fn;
		m_InitWhenChangeStateFns[state] = init_fn;
	}

	protected virtual void InitCall()
	{
	}

	public void ChangeState(string state)
	{
		if (DisabledOnMpMode && !IsMultiplayerAuthority()){
			return;
		}
		m_Blackboard["current_state"] = state;
		Action init_when_change_state_fn = m_InitWhenChangeStateFns[state];
		if (init_when_change_state_fn != null){
			init_when_change_state_fn();
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		var current_state = m_Blackboard["current_state"] as string;
		Action state_fn = m_StateFns[current_state];
		state_fn();
	}

	public virtual void SetBlackboard(string key, object value)
	{
		if (DisabledOnMpMode && !IsMultiplayerAuthority()){
			return;
		}
		m_Blackboard[key] = value;
	}

	public virtual object GetBlackboard(string key)
	{
		if (DisabledOnMpMode && !IsMultiplayerAuthority()){
			return null;
		}
		return m_Blackboard[key];
	}

}
