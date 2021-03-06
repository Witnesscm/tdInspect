#!/usr/bin/env node
/**
 * @File   : DataGen.js
 * @Author : Dencer (tdaddon@163.com)
 * @Link   : https://dengsir.github.io
 * @Date   : 5/21/2020, 10:31:02 PM
 */

const fs = require("fs");
const got = require("got");

const LOCALES = ["enUS", "deDE", "esES", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN"];

const TALENTS = "https://classic.wowhead.com/data/talents-classic";
const LOCALE = "https://wow.zamimg.com/js/locale/classic.enus.js";

const BACKGROUNDS = {
    ["283"]: "DruidBalance",
    ["281"]: "DruidFeralCombat",
    ["282"]: "DruidRestoration",
    ["361"]: "HunterBeastMastery",
    ["363"]: "HunterMarksmanship",
    ["362"]: "HunterSurvival",
    ["81"]: "MageArcane",
    ["41"]: "MageFire",
    ["61"]: "MageFrost",
    ["382"]: "PaladinHoly",
    ["383"]: "PaladinProtection",
    ["381"]: "PaladinCombat",
    ["201"]: "PriestDiscipline",
    ["202"]: "PriestHoly",
    ["203"]: "PriestShadow",
    ["182"]: "RogueAssassination",
    ["181"]: "RogueCombat",
    ["183"]: "RogueSubtlety",
    ["261"]: "ShamanElementalCombat",
    ["263"]: "ShamanEnhancement",
    ["262"]: "ShamanRestoration",
    ["302"]: "WarlockCurses",
    ["303"]: "WarlockSummoning",
    ["301"]: "WarlockDestruction",
    ["161"]: "WarriorArms",
    ["164"]: "WarriorFury",
    ["163"]: "WarriorProtection",
};

function getTalentData(body) {
    const m = body.match(/WH\.Wow\.TalentCalcClassic\.data=({[^;]+});/);
    const data = JSON.parse(m[1]).talents;
    return data;
}

function getClassTalents(body) {
    const m = body.match(/var mn_spells=(.+);\(function/);

    for (const item of eval(m[1])) {
        if (item[1] === "Talents") {
            return item[3]
                .map((t) => [t[1], t[3].map((r) => r[0])])
                .reduce((t, v) => {
                    t[v[0]] = v[1];
                    return t;
                }, {});
        }
    }
}

function getTalentLocales(body) {
    const m = body.match(/var g_chr_specs=({[^;]+});/);
    return JSON.parse(m[1]);
}

async function genTalents() {
    const ClassTalents = getClassTalents((await got(LOCALE)).body);
    const Talents = getTalentData((await got(TALENTS)).body);
    const Locales = {};

    for (const locale of LOCALES) {
        Locales[locale] = getTalentLocales(
            (await got(`https://wow.zamimg.com/js/locale/classic.${locale.toLowerCase()}.js`)).body
        );
    }

    const file = fs.createWriteStream("Data/Talents.lua");

    file.write(`-- GENERATE BY DataGen.js
select(2,...).Data()`);

    for (const [cls, tabIds] of Object.entries(ClassTalents)) {
        file.write(`C'${cls.toUpperCase()}'`);

        for (const tabId of tabIds) {
            const talents = Object.values(Talents[tabId]).sort((a, b) => a.row * 10 + a.col - b.row * 10 - b.col);

            file.write(`T('${BACKGROUNDS[tabId]}',${talents.length})`);

            for (const locale of LOCALES) {
                file.write(`N('${locale}','${Locales[locale][tabId]}')`);
            }

            for (const talent of talents) {
                file.write(`I(${talent.row + 1},${talent.col + 1},${talent.ranks.length})`);
                file.write(`R{${talent.ranks.join(",")}}`);

                if (talent.requires) {
                    for (const req of talent.requires) {
                        const reqTalent = Talents[tabId][req.id];
                        file.write(`P(${reqTalent.row + 1},${reqTalent.col + 1})`);
                    }
                }
            }
        }
    }
    file.end("", "utf-8");
}

async function main() {
    await genTalents();
}

main();
