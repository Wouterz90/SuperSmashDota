function HeroRatingsPlayerTable()
  local HeroRatings = {
    puckValues = {
      Animations =    3,
      Disables =      1,
      Cooldowns =     3,
      Evasiveness =   3,
      Push =          1,
      Damage =        0,
      Likelyness =    1,
    },
    tuskValues = {
      Animations =    1,
      Disables =      1,
      Cooldowns =     2,
      Evasiveness =   1,
      Push =          2,
      Damage =        1,
      Likelyness =    3,
    },
    linaValues = {
      Animations =    1,
      Disables =      1,
      Cooldowns =     1,
      Evasiveness =   2,
      Push =          1,
      Damage =        3,
      Likelyness =    1,
    },
    earthshakerValues = {
      Animations =    1,
      Disables =      3,
      Cooldowns =     0,
      Evasiveness =   2,
      Push =          3,
      Damage =        1,
      Likelyness =    2,
    },
    miranaValues = {
      Animations =    2,
      Disables =      3,
      Cooldowns =     1,
      Evasiveness =   3,
      Push =          0,
      Damage =        1,
      Likelyness =    0,
    },
    tinkerValues = {
      Animations =    0,
      Disables =      0,
      Cooldowns =     3,
      Evasiveness =   0,
      Push =          1,
      Damage =        3,
      Likelyness =    2,
    },
    rattletrapValues = {
      Animations =    2,
      Disables =      1,
      Cooldowns =     0,
      Evasiveness =   1,
      Push =          3,
      Damage =        1,
      Likelyness =    1,
    },
    zuusValues = {
      Animations =    2,
      Disables =      0,
      Cooldowns =     2,
      Evasiveness =   0,
      Push =          2,
      Damage =        2,
      Likelyness =    2,
    },
  }

  PlayerTables:CreateTable("heroRatings",HeroRatings,true)

end
