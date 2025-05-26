= start
你好，欢迎来到测试对话！
这是一段直接显示的文字，后面会有选项。
-> choices_section

= choices_section
你想怎么开始？
+ “打个招呼”:
    -> greet
+ “跳过介绍”:
    -> skip_intro

= greet
你：你好！  
NPC：你好，很高兴见到你。  
-> after_greet

= skip_intro
NPC：好的，我们直接进入正题。  
-> after_greet

= after_greet
这里没有选项的段落，会直接显示，然后继续下一步。  
-> second_choices


= second_choices
请选择一个动作：
+ “看看周围”:
    周围的景色非常美丽。  
    -> end
+ “离开”:
    你决定离开这里。  
    -> end
+ “不做任何事”:
    你静静地站着，什么也没做。  
    -> end

= end
对话结束，谢谢测试！  
