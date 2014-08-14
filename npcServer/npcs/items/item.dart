part of coUserver;

abstract class Item
{
	String iconUrl, spriteUrl, name, description, id;
	int price, stacksTo, iconNum = 4;
	num x,y;
	bool onGround = false;
	List<Map> actions = [{"action":"drop",
						  "timeRequired":0,
						  "enabled":true,
						  "actionWord":""}];
	
	Map getMap()
	{
		return {"iconUrl":iconUrl,
				"spriteUrl":spriteUrl,
				"name":name,
				"description":description,
				"price":price,
				"stacksTo":stacksTo,
				"iconNum":iconNum,
				"id":id,
				"onGround":onGround,
				"x":x,
				"y":y,
				"actions":actions};
	}
	
	void pickup({WebSocket userSocket})
	{
		Map map = {};
		map['giveItem'] = "true";
		map['item'] = getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
		onGround = false;
	}
	
	void drop({WebSocket userSocket, Map map, String streetName})
	{
		num x = map['x'], y = map['y'];
		String id = "i" + createId(x,y,map['dropItem']['name'],map['tsid']);
		actions.clear();
		actions.add({"action":"pickup","enabled":true,"timeRequired":0,"actionWord":""});
		this.id = id;
		onGround = true;
		this.x = x;
		this.y = y;
		StreetUpdateHandler.streets[streetName].groundItems[id] = this;
		log("dropped item: ${getMap()}");
		
		Map takeMap = {}
			..['takeItem'] = "true"
			..['name'] = map['dropItem']['name']
			..['count'] = map['count'];
		userSocket.add(JSON.encode(takeMap));
	}
}