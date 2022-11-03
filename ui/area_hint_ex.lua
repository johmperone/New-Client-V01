
function layWorld_hntAreaHint_OnLoad(self)
	self:RegisterScriptEventNotify("EVENT_SelfAreaChanged"); -- �Լ�������
	self:RegisterScriptEventNotify("EVENT_SelfEnterWarArea"); -- �Լ������ս����
	self:RegisterScriptEventNotify("EVENT_SelfLeaveWarArea"); -- �Լ��뿪��ս����
end

function layWorld_hntAreaHint_OnEvent(self, event, args)
	if event == "EVENT_SelfAreaChanged" then
		layWorld_hntAreaHint_OnEvent_SelfAreaChanged(self, event, args);
	elseif event == "EVENT_SelfEnterWarArea" then
		layWorld_hntAreaHint_OnEvent_SelfEnterWarArea(self, event, args);
	elseif event == "EVENT_SelfLeaveWarArea" then
		layWorld_hntAreaHint_OnEvent_SelfLeaveWarArea(self, event, args);
	end
end

function layWorld_hntAreaHint_OnEvent_SelfAreaChanged(self, event, args)
	local userid = args[1];
	local areaname = args[2];
	
	local rtext = EvUiLuaClass_RichText:new();
	local line = EvUiLuaClass_RichTextLine:new();
	local item = EvUiLuaClass_RichTextItem:new();
	item.Text = areaname;
	item.Font = LAN("font_title");
	item.Color = "#ff09ff11";
	line:InsertItem(item);
	rtext:InsertLine(line);
	
	self:SetRichText(rtext:ToRichString());
	self:ActiveAnchor();
	self:ShowAndFocus();
end

function layWorld_hntAreaHint_OnEvent_SelfEnterWarArea(self, event, args)
	local areaname = LAN("msg_war_zone_enter");
	
	local rtext = EvUiLuaClass_RichText:new();
	local line = EvUiLuaClass_RichTextLine:new();
	local item = EvUiLuaClass_RichTextItem:new();
	item.Text = areaname;
	item.Font = LAN("font_title");
	item.Color = "#ff09ff11";
	line:InsertItem(item);
	rtext:InsertLine(line);
	
	self:SetRichText(rtext:ToRichString());
	self:ActiveAnchor();
	self:ShowAndFocus();
end

function layWorld_hntAreaHint_OnEvent_SelfLeaveWarArea(self, event, args)
	local areaname = LAN("msg_war_zone_leave");
	
	local rtext = EvUiLuaClass_RichText:new();
	local line = EvUiLuaClass_RichTextLine:new();
	local item = EvUiLuaClass_RichTextItem:new();
	item.Text = areaname;
	item.Font = LAN("font_title");
	item.Color = "#ff09ff11";
	line:InsertItem(item);
	rtext:InsertLine(line);
	
	self:SetRichText(rtext:ToRichString());
	self:ActiveAnchor();
	self:ShowAndFocus();
end


