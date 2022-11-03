

function Local_Item_UseItemDispatcher_18 (self, step)
	local UseCursor = EV_GAME_CURSOR_DECOMPOSE;
	if step == 1 then -- ��һ��,ʹ�õ���
		return uiSetGameCursor(UseCursor);
	elseif step == 2 then
		local cursor = uiGetGameCursor();
		if cursor ~= UseCursor then return false end -- ��鵱ǰͼ��״̬
		
		local id = self.VarSkillTarget;
		if id == nil or id == 0 then return nil end
		local objInfo = uiItemGetBagItemInfoByObjectId(id);
		local index = objInfo.TableId; -- ���߱��id
		if index == nil or index == 0 then return nil end
		local classInfo = uiItemGetItemClassInfoByTableIndex(index);
		if classInfo == nil then return nil end
		---------------  ���ͨ��  -----------------
		local TargetName = classInfo.Name;
		local title = "";
		local msg = string.format(LAN("MSG_DECOMP_CONFIRM"), TargetName); -- ��ȷ��Ҫ�ֽ�[%s]��
		---------------  ��ʾ���  -----------------
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
			param		=	self.VarSkillTarget,
			Operation	=	self.Operation,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param, Arg.Operation) end, nil, MsgArg);
		uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
		return false; -- ��ûʹ�ý���
	end
end

Local_Skill_UseSkillDispatcher = -- ����ʹ�õķַ��� -- ָ�� ĳһ ���� ���� ʹ�÷�ʽ
{
	VarSkillUse = 0,
	VarSkillTarget = 0,
	Operation = 0,
	[18] = Local_Item_UseItemDispatcher_18,		-- �ֽ�
}

function Local_Skill_UseSkillDispatcher:Init()
	self:Reset();
end

function Local_Skill_UseSkillDispatcher:Reset()
	self.VarSkillUse = 0;
	self.VarSkillTarget = 0;
	Operation = 0;
	uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
end

function Local_Skill_UseSkillDispatcher:IsProcessing()
	local cursor = uiGetGameCursor();
	if self.VarSkillUse == 0 or (cursor ~= EV_GAME_CURSOR_SKILLONCRE and cursor ~= EV_GAME_CURSOR_DECOMPOSE) then
		return false;
	end
	return true;
end

function Local_Skill_UseSkillDispatcher:Use(id, usetoself, _op) -- idΪ���ܵ�index -- _opΪ��Ҳ���
	if Local_Item_UseItemDispatcher then
		Local_Item_UseItemDispatcher:Reset();
	end
	self:Reset();
	self.VarSkillUse = id;
	if self.VarSkillUse == nil then self.VarSkillUse = 0 return end
	local info = uiSkill_GetSkillBaseInfoByIndex(self.VarSkillUse);
	if info == nil then self.VarSkillUse = 0 return end
	--[[
	if usetoself then
		if info["m_ReleaseParam.TargetType"] == 1 then
			local myObjectId = uiGetMyInfo("ObjectId");
			uiSetGameCursor(EV_GAME_CURSOR_SKILLONCRE);
			return self:Target(myObjectId);
		end
	end
	]]
	self.Operation = _op;
	if self[id] == nil then id = "_Default_" end -- ���û��ע���Ӧ�ĺ���,��ʹ��Ĭ�Ϻ���
	return self[id](self, 1);
end

function Local_Skill_UseSkillDispatcher:Target(targetid) -- idΪĿ��
	self.VarSkillTarget = targetid;
	local id = self.VarSkillUse;
	if self[id] == nil then id = "_Default_" end -- ���û��ע���Ӧ�ĺ���,��ʹ��Ĭ�Ϻ���
	local bResult = self[id](self, 2);
	if bResult then
		self:Reset();
	end
	return bResult;
end

function Local_Skill_UseSkillDispatcher:Release(param, _op) -- param ���� ��ͬ�ĵ��� ���������ͺ�������ܲ���
	local bResult = false;
	if param == nil then param = 0 end
	if _op == nil then _op = 0 end
	
	local id = self.VarSkillUse;
	if id == 0 then return end
	
	bResult = uiSkill_ReleaseSkill(id, param, _op);
	--[[
	if bResult then
		self:Reset();
	end
	]]
	return bResult;
end

-- Ĭ�ϵĴ���
function Local_Skill_UseSkillDispatcher:_Default_(step)
	if step == 1 then -- ��һ��
		return self:Release(0, self.Operation);
	else
		local cursor = uiGetGameCursor();
		if cursor ~= EV_GAME_CURSOR_SKILLONCRE then return false end
		return self:Release(self.VarSkillTarget, self.Operation);
	end
end




