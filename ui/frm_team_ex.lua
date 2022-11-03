
function frmTeamEx_TemplateFrmTeamMember_btHead_OnRClick(self)
	local form = SAPI.GetParent(self);
	if self == nil then return end
	local ID = form.ID;
	local evid, id, is_captain, buff_list, online, icon, name, level, party, hp, maxhp, mp, maxmp = uiTeamGetMemberInfo(ID);
	uiShowPopmenuPlayer(name, online);
end

function frmTeamEx_TemplateFrmTeamMember_btHead_OnLClick(self)
	local form = SAPI.GetParent(self);
	if self == nil then return end
	local ID = form.ID;
	local evid, id, is_captain, buff_list, online, icon, name, level, party, hp, maxhp, mp, maxmp = uiTeamGetMemberInfo(ID);
	if Local_Skill_UseSkillDispatcher:IsProcessing() and Local_Skill_UseSkillDispatcher:Target(id) then
	else
		uiUserSetTarget(id);
	end
end

function frmTeamEx_TemplateFrmTeamMember_OnLoad(self)
	self:RegisterScriptEventNotify("EVENT_TeamRefresh");
end

function frmTeamEx_TemplateFrmTeamMember_OnEvent(self, event, args)
	if event == "EVENT_TeamRefresh" then
		frmTeamEx_TemplateFrmTeamMember_Reresh(self);
	end
end

function frmTeamEx_TemplateFrmTeamMember_Reresh(self)
	if self == nil then return end
	local ID = self.ID;
	if ID == nil then self:Hide() return end
	local evid, id, is_captain, buff_list, online, icon, name, level, party, hp, maxhp, mp, maxmp = uiTeamGetMemberInfo(ID);
	if evid == nil then self:Hide() return end
	-- �ӳ�
	local lbLeader = SAPI.GetChild(self, "lbLeader");
	if is_captain then
		lbLeader:Show();
	else
		lbLeader:Hide();
	end
	-- �Ƿ�����
	local btHead = SAPI.GetChild(self, "btHead");
	if not online or not icon then
		icon = "team_member_offline";
	end
	btHead:SetNormalImage(SAPI.GetImage(icon));
	-- ����
	local lbName = SAPI.GetChild(self, "lbName");
	lbName:SetText(name);
	-- �ȼ�
	local lbLev = SAPI.GetChild(self, "lbLev");
	lbLev:SetText(tostring(level));
	-- ���� (ֻҪhint����ʾ)
	-- HP
	local pbHP = SAPI.GetChild(self, "pbHP");
	pbHP:SetText(string.format("%d / %d", hp, maxhp));
	pbHP:SetValue(hp/maxhp);
	-- MP or EP (ħ��������)
	local pbMP = SAPI.GetChild(self, "pbMP");
	local pbEP = SAPI.GetChild(self, "pbEP");
	if party == EV_PARTY_QC or party == EV_PARTY_FM then
		pbMP:Hide();
		pbEP:Show();
		pbEP:SetText(string.format("%d / %d", mp, maxmp));
		pbEP:SetValue(mp/maxmp);
	else
		pbEP:Hide();
		pbMP:Show();
		pbMP:SetText(string.format("%d / %d", mp, maxmp));
		pbMP:SetValue(mp/maxmp);
	end
	-- buff
	local lbByfuTitle = SAPI.GetChild(self, "lbByfuTitle");
	for i = 1, 16, 1 do
		local lbByfu = SAPI.GetChild(lbByfuTitle, "lbByfu"..i);
		if not lbByfu then break end
		local buffid = buff_list[i];
		if buffid then
			local index, icon = uiSkill_GetEffectClassInfo(buffid);
			if index then
				lbByfu:SetBackgroundImage(SAPI.GetImage(icon));
				lbByfu:Show();
			else
				lbByfu:Hide();
			end
		else
			lbByfu:Hide();
		end
	end
	
	local petid, online, hp, maxhp = uiTeamGetMemberPetInfo(ID);
	local frmPet = SAPI.GetChild(self, "frmPet");
	if petid and online then
		frmPet:Show();
		local pbPetHP = SAPI.GetChild(frmPet, "pbPetHP");
		pbPetHP:SetValue(hp/maxhp);
	else
		frmPet:Hide();
	end
	self:Show();
end

function frmTeamEx_TemplateFrmTeamMember_frmPet_OnLClick(self)
	local form = SAPI.GetParent(self);
	if self == nil then return end
	local ID = form.ID;
	local petid, online, hp, maxhp = uiTeamGetMemberPetInfo(ID);
	if petid and online then
		if Local_Skill_UseSkillDispatcher:IsProcessing() and Local_Skill_UseSkillDispatcher:Target(petid) then
		else
			uiUserSetTarget(petid);
		end
	end
end


