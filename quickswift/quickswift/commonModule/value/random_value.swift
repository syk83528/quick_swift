//
//  random_value.swift
//  quickswift
//
//  Created by suyikun on 2022/7/27.
//

import Foundation

struct Random {
    
    private init() { }
    
    static func execute<T>(_ block: () -> T, count: Int) -> [T] {
        var temp: [T] = []
        for _ in 0 ..< count {
            temp.append(block())
        }
        return temp
    }
    
    static func avatar() -> String {
        let avatars = ["https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/77252a3623e546a9a31aaafed9ee1333.jpg!sswm",
                       "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/b21b2bfaa1354a6f8a8e8b0c9860b31c.jpg!sswm",
                       "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/8e414e940cf14f548ae199ee5d8886a2.jpg!sswm",
                       "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/15360819e46e4a5b8b9539632efb947c.jpg!sswm"
        ]
        return avatars.random!
    }
    
    static func image() -> String {
        let imgs = ["https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/fc7555f69a9c4437bd0d21fe9b16b124.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/cf4710a279fa477e822143160f8e84cb.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/55540c3d94454de0a7492fbf13569a96.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/5eef90104bfb4fcdbd520dd4f46ff585.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/798b620e0d3f4a0c9885aabad79458e9.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/ac812ced960f4b8db6a23bd8767f9ea9.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/315ad33c1d07494c8bb10d5773ac1cd5.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/8930260bc04b45b19afe735daf1a1117.png!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/142d16c1af0e456d935a4a50e5cacf25.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/0b08997551ea48548ef68261f611e693.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/45db19bb34974688826d61758e9d8c67.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/482a8b7b6d5d484d8f00b01b5f88dd35.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/6bb4036e7ad941b3899d9948ef654bc2.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/8c7b5a80ecca461280b5f482e3be506e.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/8097a579f418496d8f2e6099e1f1d578.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/412aabf991df4df6aa62c9b599c552b1.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/5d6e2b9bbead450e80683b328e0664a9.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/3748598f5e974a8fbd77a73a3ef7fa45.jpg!sswm",
                    "https://ssyerv1.oss-cn-hangzhou.aliyuncs.com/picture/d8c259dbf4634145adc0427d242f5757.jpg!sswm"
        ]
        return imgs.random!
    }

    static func images() -> String {
        
        let count = Int.random(to: 9)
        if count == 0 {
            return ""
        }
        
        var images: [String] = []
        for _ in 0 ..< count {
            images.append(image())
        }
        return images.joined(separator: ",")
    }
    
    static func signature() -> String {
        
        let signs = ["不要让我在乎你，你让我在乎了你，你就必须在乎我",
                     "真正的幸福，不是活成别人那样，而是能够按照自己的意愿去生活。",
                     "旧时光就是本流水账，有些事情，没法回忆。",
                     "我不哭，不是因为我坚强，而是为了让你哭的时候还能有所依靠。",
                     "我们有多长时间没联系了。你一直不曾回头，我却始终对你微笑。",
                     "幸福很短暂，还长着翅膀会飞。快乐太单纯，所以很容易破碎。",
                     "人会老，爱情也会。放着大量防腐剂的食物都有着变质的危险。",
                     "如果一个人真的想见你，他会动用各种方式，翻遍全世界找到你。",
                     "总有那么一个人，心里总想着，但却刻意不会再去联系，不去打听，不去打扰",
                     "明明说着看开了，却总是在微笑沉醉时输给了现实，只因想到了伤痛。",
                     "我需要牵着你的手，才能告诉你什么是永远。",
                     "如果有一天我放弃了，你要知道是因为你的不在乎。",
                     "别人爱怎么想那是他们的事，你就是你。",
                     "有一天，我会完美蜕变，再重新走到你面前，让你惊艳",
                     "你为了另一个人活了太久太久，现在你要好好做自己了。",
                     "失去的东西，其实从来未曾真正地属于你，也不必惋惜。",
                     "如果我放弃，不是因为我输了，而是因为我懂了。",
                     "每一个矜持淡定的现在，都有一个很傻逼很天真的曾经。",
                     "既然看不清未来，又没办法回到过去，那就活在当下吧！",
                     "越想拥有的东西往往越得不到、其实我们心里都知道",
                     "阳光温和，岁月静好，你若不来，我怎敢老去。",
                     "我很好，不吵不闹不炫耀，不要委屈不要嘲笑，也不需要别人知道。",
                     "真正的情歌，让悲伤更加悲伤，让寂寞更加寂寞。",
                     "人生最大的痛苦莫过于经历了超级风雨后，不但没看到彩虹，结果还感冒了。",
                     "你听说过我，不代表你了解我。你听过一些流言，不代表就是真的。",
                     "你若一向在、我便一向爱。惋惜没人会懂我的。",
                     "我觉得自己像是一只，被凝胶凝固在琥珀中的昆虫。",
                     "笑有时候并不是最好的良药，有时候它只是最好的掩饰而已。",
                     "听说幸福很简单、简单到时间一冲就冲淡。",
                     "当我给不起的时候，我所能做的，只有离开。",
                     "人的一生会遇到两个人，一个惊艳了时光，一个温柔了岁月。"]
        return signs.random!
    }
    
    static func poem() -> String {
        
        let poems = ["""
行宫
唐代：元稹

寥落古行宫，宫花寂寞红。
白头宫女在，闲坐说玄宗。
""", """
黄鹤楼送孟浩然之广陵
唐代：李白

故人西辞黄鹤楼，烟花三月下扬州。
孤帆远影碧空尽，唯见长江天际流。 (唯 通：惟)
""", """
兵车行
唐代：杜甫

车辚辚，马萧萧，行人弓箭各在腰。
耶娘妻子走相送，尘埃不见咸阳桥。(耶娘 一作：爷娘)
牵衣顿足拦道哭，哭声直上干云霄。
道旁过者问行人，行人但云点行频。
或从十五北防河，便至四十西营田。
去时里正与裹头，归来头白还戍边。
边庭流血成海水，武皇开边意未已。
君不闻，汉家山东二百州，千村万落生荆杞。
纵有健妇把锄犁，禾生陇亩无东西。
况复秦兵耐苦战，被驱不异犬与鸡。
长者虽有问，役夫敢申恨？
且如今年冬，未休关西卒。
县官急索租，租税从何出？
信知生男恶，反是生女好。
生女犹得嫁比邻，生男埋没随百草。
君不见，青海头，古来白骨无人收。
新鬼烦冤旧鬼哭，天阴雨湿声啾啾！
""", """
无题·昨夜星辰昨夜风
唐代：李商隐

昨夜星辰昨夜风，画楼西畔桂堂东。
身无彩凤双飞翼，心有灵犀一点通。
隔座送钩春酒暖，分曹射覆蜡灯红。
嗟余听鼓应官去，走马兰台类转蓬。
""", """
芙蓉楼送辛渐
唐代：王昌龄

寒雨连江夜入吴，平明送客楚山孤。
洛阳亲友如相问，一片冰心在玉壶。
"""]
        return poems.random!
    }
    
}

extension Array {
    
    var random: Element? {
        guard self.count > 0 else {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
}
