part of entity;

class EarthshakerRespawningItem extends RespawningItem {
	EarthshakerRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Earthshaker';
		itemType = 'earthshaker';
		respawnTime = new Duration(hours: 1);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/earthshaker__x1_1_x1_2_x1_3_x1_4_png_1354829806.png',
				144, 46, 36, 46, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
