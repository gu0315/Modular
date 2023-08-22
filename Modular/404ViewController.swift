//
//  404ViewController.swift
//  Modular
//
//  Created by 顾钱想 on 2023/8/22.
//

import UIKit

class _04ViewController: UIViewController, ModuleProtocol {
    static func moduleDescription(description: ModuleDescription) {
        description.moduleName("404")
            .method { method in
                method.name("push")
                      .selector(selector: #selector(push404))
                      .parameterDescription { enumerator in }
            }
        }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "404"
        // Do any additional setup after loading the view.
    }
    
    @objc func push404() {
        let vc = _04ViewController()
        guard let topVc = TestSwiftViewController.applicationTopVC() else {
            return
        }
        topVc.navigationController?.pushViewController(vc, animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
