/*
The MIT License (MIT)

Copyright (c) 2015 Tomoya Kanehira

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

plugin modifier ScalableBone
name:"ScalableBone"
classID:#(0x212fc9f4, 0x6db62605)
replaceUI:true
version:1
(
	parameters main rollout:params
	(
		NodeFrom	type:#node
		NodeTo		type:#node
		NodeUp		type:#node
	)	
	
	on attachedToNode obj do
	(
		if ((classof  obj.baseObject) != BoneGeometry) then
		(
			messagebox "Only \"BoneGeometry\" can be added!! "
			deleteModifier obj this
		)		
	)
	
	rollout params "Select Node"
	(
		pickbutton  pb_from			"From"				width:160
		pickbutton  pb_to			"To"					width:160
		pickbutton  pb_up			"LookAt Up"		width:160
		--
		
		fn func_ApplyEnabled =
		(
			this.operation.bt_apply.enabled  = false
			this.operation.bt_bakeKey.enabled  = false
			
			if (NodeFrom != undefined and NodeTo != undefined) then
			(
				this.operation.bt_apply.enabled  = true
				this.operation.bt_bakeKey.enabled  = false
			)	
		)			
		
		on params open do
		(
			if (NodeFrom != undefined) then
				pb_from.text = NodeFrom.name
			
			if (NodeTo != undefined) then
				pb_to.text = NodeTo.name			
			
			func_ApplyEnabled()
		)
		
		on pb_from picked obj do
		( 
			if obj != undefined do
			(
				NodeFrom = obj
				pb_from.text = obj.name
			)
			
			func_ApplyEnabled()	
		)
		
		on pb_to picked obj do
		( 
			if obj != undefined do
			(
				NodeTo = obj
				pb_to.text = obj.name
			)

			func_ApplyEnabled()		
		)	

		on pb_up picked obj do
		( 
			if obj != undefined do
			(
				NodeUp = obj
				pb_up.text = obj.name
			)
		)			
		

	)		
	
	rollout operation "Operation"
	(
		button 		bt_apply			"Apply"				width:160
		button 		bt_bakeKey		"Bake Key"			width:160
		
		on operation open do
		(
			this.params.func_ApplyEnabled()
		)		
		
		on bt_apply pressed do
		(
			local _mineNodes = refs.dependentNodes this
			
			local _length = distance NodeFrom NodeTo
			
			for _i = 1 to _mineNodes.count do
			(
				local _mineNode = _mineNodes[_i]
				
				local _length = _mineNode.length
				
				_mineNode.pos.controller = Position_XYZ ()
				_mineNode.rotation.controller = Euler_XYZ ()
				_mineNode.scale.controller = tcb_scale ()
				
				_mineNode.pos.controller = Position_Constraint ()
				_mineNode.pos.controller.appendTarget NodeFrom 50
				
				_mineNode.rotation.controller = LookAt_Constraint ()
				
				if (NodeUp != undefined) then
				(
					_mineNode.rotation.controller.upnode_world = off
					_mineNode.rotation.controller.pickUpNode = NodeUp
				)
				_mineNode.rotation.controller.appendTarget NodeTo 50 
				_mineNode.rotation.controller.lookat_vector_length = 1
				
				_mineNode.scale.controller = scale_script ()
				_mineNode.scale.controller.AddNode "nodeFrom" NodeFrom
				_mineNode.scale.controller.AddNode "nodeTo" NodeTo
				_mineNode.scale.controller.AddConstant "valueRef" _length
				_mineNode.scale.controller.script = "local _length = distance nodeFrom nodeTo \n[_length / valueRef, 1, 1]"				
			)
		)		
		
		on bt_bakeKey pressed do
		(
			local _mineNodes = refs.dependentNodes this
			
			for _i = 1 to _mineNodes.count do
			(
				local _mineNode = _mineNodes[_i]
				
				-- position
				_mineNode.pos.controller = NodeFrom.pos.controller
				
				-- rotation
				/*
				local _formKeys = NodeFrom.pos.controller.keys
				local _toKeys = NodeTo.pos.controller.keys
				*/
			)				
		)
	)		
)