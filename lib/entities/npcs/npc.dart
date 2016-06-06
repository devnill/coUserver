part of entity;

abstract class NPC extends Entity {
	/**
	 * The actions map key string should be equivalent to the name of a function
	 * as it will be dynamically called in street_update_handler when the client
	 * attempts to perform one of the available actions;
	 * */

	static int updateFps = 20;

	String id, type, streetName;
	int x,
		y,
		speed = 0,
		ySpeed = 0,
		yAccel = -2400,
		previousX,
		previousY;
	bool facingRight = true;
	MutableRectangle _collisionsRect;

	NPC(this.id, this.x, this.y, this.streetName) {
		respawn = new DateTime.now();
	}

	int get width => currentState.frameWidth;

	int get height => currentState.frameHeight;

	Street get street => StreetUpdateHandler.streets[streetName];

	Rectangle get collisionsRect {
		if (_collisionsRect == null) {
			_collisionsRect = new MutableRectangle(x, y, width, height);
		} else {
			_collisionsRect.left = x;
			_collisionsRect.top = y;
			_collisionsRect.width = width;
			_collisionsRect.height = height;
		}

		return _collisionsRect;
	}

	int getYFromGround(num cameFrom) {
		int returnY = y;
		if (street == null) {
			return returnY;
		}

		CollisionPlatform platform = street.getBestPlatform(cameFrom, x, width, height);
		if (platform != null) {
			num goingTo = y + street.groundY;
			num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
			num yInt = platform.start.y - slope * platform.start.x;
			num lineY = slope * x + yInt;

			if (goingTo >= lineY) {
				returnY = lineY.toInt() - street.groundY;
				ySpeed = 0;
			}
		}

		return returnY ~/ 1;
	}

	void update() {
		previousX = x;
		previousY = y;
	}

	void defaultWallAction(Wall wall) {
		facingRight = !facingRight;

		if(wall == null) {
			return;
		}

		if (facingRight) {
			if (collisionsRect.right >= wall.bounds.left) {
				x = wall.bounds.left - width - 1;
			}
		} else {
			if (collisionsRect.left < wall.bounds.left) {
				x = wall.bounds.right + 1;
			}
		}
	}

	void defaultLedgeAction() {
		y = previousY;
		x = previousX;
		facingRight = !facingRight;
	}

	void defaultXAction() {
		if (facingRight) {
			x += speed ~/ NPC.updateFps;
		} else {
			x -= speed ~/ NPC.updateFps;
		}
	}

	void defaultYAction() {
		ySpeed -= yAccel ~/ NPC.updateFps;
		y += ySpeed ~/ NPC.updateFps;
		y = getYFromGround(previousY);
	}

	///Move the entity 'forward' according to which direction they are facing
	///and based on the platform lines available on the street
	///
	///If the entity should perform actions other than the defaults at certain
	///conditions (such as walls and ledges etc.) then pass those as function  pointers
	///else the default action will be taken
	void moveXY({Function xAction, Function yAction, Function wallAction, Function ledgeAction}) {
		if(previousY == null) {
			throw "Did you forget to call super.update()?";
		}

		if (wallAction == null) {
			wallAction = defaultWallAction;
		}
		if (ledgeAction == null) {
			ledgeAction = defaultLedgeAction;
		}
		if (xAction == null) {
			xAction = defaultXAction;
		}
		if (yAction == null) {
			yAction = defaultYAction;
		}

		xAction();
		yAction();

		//if our new y value is more than 10 pixels away from the old one
		//we probably changed platforms (dropped down) so decide what to do about that
		if ((y - previousY).abs() > 10) {
			ledgeAction();
		}

		//stop walking into walls, take an action if we're colliding with one
		for (Wall wall in street.walls) {
			if (collisionsRect.intersects(wall.bounds)) {
				wallAction(wall);
			}
		}

		//treat the sides of the street as walls too
		if (x < 0) {
			wallAction(null);
			x = 0;
		}

		if ((street?.bounds) != null && x > street.bounds.width - width) {
			wallAction(null);
			x = street.bounds.width - width;
		}
	}

	Map getMap() {
		Map map = super.getMap();
		map["id"] = id;
		map["url"] = currentState.url;
		map["type"] = type;
		map["numRows"] = currentState.numRows;
		map["numColumns"] = currentState.numColumns;
		map["numFrames"] = currentState.numFrames;
		map["x"] = x;
		map["y"] = y;
		map['speed'] = speed;
		map['ySpeed'] = ySpeed;
		map['animation_name'] = currentState.stateName;
		map["width"] = width;
		map["height"] = height;
		map['loops'] = currentState.loops;
		map['loopDelay'] = currentState.loopDelay;
		map["facingRight"] = facingRight;
		map["actions"] = actions;
		return map;
	}
}
