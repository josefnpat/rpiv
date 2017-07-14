musicdata = {level={},boss={},cutscene={}}
sfxdata = {}

-- Music that plays in menu and upgrade screens
musicdata.menu = 29

-- Music that plays during cutscenes
musicdata.cutscene[1] = 30 -- cutscene before level 1
musicdata.cutscene[2] = 30 -- cutscene before level 2
musicdata.cutscene[3] = 30 -- cutscene before level 3
musicdata.cutscene[4] = 31 -- cutscene after level 3 (You won the game!)

-- Music that plays during levels
musicdata.level[1] = 31
musicdata.level[2] = 00
musicdata.level[3] = 19

-- Music that plays during bossfights
musicdata.boss[1] = 54
musicdata.boss[2] = 11
musicdata.boss[3] = 48

-- SFX for the game
sfxdata.explosion = 50
sfxdata.bigexplosion = 51
sfxdata.playerdeath = 53
sfxdata.menuscroll = 54
sfxdata.weapon = 55
sfxdata.pushstart = 56
sfxdata.upgrade = 57
sfxdata.cloaking = 58
