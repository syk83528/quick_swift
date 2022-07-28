//
//  TestViewController.swift
//  quick
//
//  Created by suyikun on 2021/8/11.
//

import Foundation

class TestViewController: UIViewController {
    
    let btn = UIButton().then {
        $0.backgroundColor = .red
    }
    
    let btn2 = UIButton().then {
        $0.backgroundColor = .orange
    }
    
    let container = UIView().then {
        $0.backgroundColor = .brown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.add(to: view)
        btn.add(to: container)
        btn2.add(to: container)
        btn2.isVisible = false
//        btn2.alpha = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.pin.all(20)
        btn.pin.size(50.size).top(100).left(100)
        btn2.pin.size(50.size).top(100).left(100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        Animater().duration(1).delay(1).options([.showHideTransitionViews]).animations {
//            self.container.addSubview(self.btn)
//        }.animateTransition(with: self.container)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let fromView = btn.alpha > 0 ? btn : btn2
//        let toView = btn.alpha > 0 ? btn2 : btn
        let fromView = btn.isVisible ? btn : btn2
        let toView = btn.isVisible ? btn2 : btn
//        Animater().delay(1).duration(2).options([.showHideTransitionViews, .curveEaseInOut, .transitionFlipFromLeft]).animateTransition(from: fromView, to: toView)
        
//        Animater().delay(1).duration(2).options([.curveLinear]).animate {
//            fromView.alpha = 0
//            toView.alpha = 1
//        }
        
        print(self.btn.frame)
        print(self.btn.isVisible)
        print(self.btn.superview)
        print(self.btn2.frame)
        print(self.btn2.isVisible)
        print(self.btn2.superview)
    }
}
