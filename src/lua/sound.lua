musicdata = {level={},boss={},cutscene={}}
sfxdata = {}

-- Music that plays in menu and upgrade screens
musicdata.menu = 6

-- Music that plays during cutscenes
musicdata.cutscene[1] = 0 -- cutscene before level 1
musicdata.cutscene[2] = 14 -- cutscene before level 2
musicdata.cutscene[3] = 14 -- cutscene before level 3
musicdata.cutscene[4] = 14 -- cutscene after level 3 (You won the game!)

-- Music that plays during levels
musicdata.level[1] = 0
musicdata.level[2] = 14
musicdata.level[3] = 14

-- Music that plays during bossfights
musicdata.boss[1] = 6
musicdata.boss[2] = 6
musicdata.boss[3] = 6

-- SFX for the game
sfxdata.weapon = 50
sfxdata.explosion = 50
sfxdata.bigexplosion = 51
sfxdata.pushstart = 53