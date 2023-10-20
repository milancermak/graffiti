use graffiti::{Tag, TagImpl};

fn a_loot_bag() -> ByteArray {
    // <svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">
    // <style>.base { fill: white; font-family: serif; font-size: 14px; }</style>
    // <rect width="100%" height="100%" fill="black" />
    // <text x="10" y="20" class="base">Warhammer</text>
    // <text x="10" y="40" class="base">Studded Leather Armor</text>
    // <text x="10" y="60" class="base">Ancient Helm</text>
    // <text x="10" y="80" class="base">Wool Sash of Rage</text>
    // <text x="10" y="100" class="base">Studded Leather Boots</text>
    // <text x="10" y="120" class="base">Linen Gloves</text>
    // <text x="10" y="140" class="base">"Dragon Roar" Amulet of Anger</text>
    // <text x="10" y="160" class="base">Bronze Ring</text>
    // </svg>

    let root: Tag = TagImpl::new("svg")
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 350 350");

    let style: Tag = TagImpl::new("style")
        .content(".base { fill: white; font-family: serif; font-size: 14px; }");

    let rect: Tag = TagImpl::new("rect")
        .attr("width", "100%")
        .attr("height", "100%")
        .attr("fill", "black");

    let text_base: Tag = TagImpl::new("text").attr("x", "10").attr("class", "base");

    let text_warhammer: Tag = text_base.clone().attr("y", "20").content("Warhammer");
    let text_studded_leather_armor: Tag = text_base
        .clone()
        .attr("y", "40")
        .content("Studded Leather Armor");
    let text_ancient_helm: Tag = text_base.clone().attr("y", "60").content("Ancient Helm");
    let text_wool_sash_of_rage: Tag = text_base
        .clone()
        .attr("y", "80")
        .content("Wool Sash of Rage");
    let text_studded_leather_boots: Tag = text_base
        .clone()
        .attr("y", "100")
        .content("Studded Leather Boots");
    let text_linen_gloves: Tag = text_base.clone().attr("y", "120").content("Linen Gloves");
    let text_dragon_roar_amulet_of_anger: Tag = text_base
        .clone()
        .attr("y", "140")
        .content("\"Dragon Roar\" Amulet of Anger");
    // no need to clone for the last text
    let text_bronze_ring: Tag = text_base.attr("y", "160").content("Bronze Ring");

    root
        .insert(style)
        .insert(rect)
        .insert(text_warhammer)
        .insert(text_studded_leather_armor)
        .insert(text_ancient_helm)
        .insert(text_wool_sash_of_rage)
        .insert(text_studded_leather_boots)
        .insert(text_linen_gloves)
        .insert(text_dragon_roar_amulet_of_anger)
        .insert(text_bronze_ring)
        .build()
}
