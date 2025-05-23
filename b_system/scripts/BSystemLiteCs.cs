using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class BSystemLiteCs : Node
{

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
	[Export]
	public bool DisabledOnMpMode = false;

	public enum ThreeStateBool{
	TRUE = 0,
	FALSE = 1,
	NOTSET = 2
	}
	private Dictionary<string, PackedState> m_StateFns = new Dictionary<string, PackedState>();
	// private Dictionary<string, Action> m_InitWhenChangeStateFns = new Dictionary<string, Action>();
	protected Dictionary<string, object> m_Blackboard = new Dictionary<string, object>();

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

	public void InsertState(PackedState packed_state)
	{
		var state = packed_state.GetState();
		m_StateFns[state] = packed_state;
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
		PackedState packed_state = m_StateFns[state];
		if (packed_state != null){
			packed_state.InitWhenChangeStateFn();
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		var current_state = m_Blackboard["current_state"] as string;
		PackedState packed_state = m_StateFns[current_state];
		packed_state.StateFn();
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
