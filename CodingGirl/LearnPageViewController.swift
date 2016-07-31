//
//  LearnPageViewController.swift
//  CodingGirl
//
//  Created by Amit Mondal on 7/21/16.
//  Copyright © 2016 Amit Mondal. All rights reserved.
//

import UIKit

class LearnPageViewController: UIPageViewController {
    
    let pink = UIColor(netHex: 0xF46197)
    let lightGreen = UIColor(netHex: 0x84bc9c)
    let darkGreen = UIColor(netHex: 0x2ca58d)
    let powderWhite = UIColor(netHex: 0xfffdf7)
    let darkBlue = UIColor(netHex: 0x0a2342)
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let controllers =  [self.newColoredViewController("page1"), self.newColoredViewController("page2"), self.newColoredViewController("page3"), self.newColoredViewController("page4"), self.newColoredViewController("page5"), self.newColoredViewController("page6")]
        return controllers
    }()
    
    private func newColoredViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .Forward, animated: true, completion: nil)
        }
        stylePageControl()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func stylePageControl() {
        let pageControl = UIPageControl.appearanceWhenContainedInInstancesOfClasses([self.dynamicType])
        
        pageControl.currentPageIndicatorTintColor = UIColor(netHex: 0xF46197)
        pageControl.pageIndicatorTintColor = UIColor(netHex: 0x0A2342)
        pageControl.backgroundColor = UIColor(netHex: 0xFFFDF7)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}




extension LearnPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    /*
        This changes the navigation bar color on page turn. Commented out because it's too jarring.
     
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if (!completed)
        {
            return
        }
        let controller = pageViewController.viewControllers!.first!
        //let nextController = pageViewController.viewControllers![1]
        let index = controller.restorationIdentifier
        switch index! {
        case "page3":
            controller.navigationController?.navigationBar.barTintColor = darkBlue
            
        case "page2":
            controller.navigationController?.navigationBar.barTintColor = darkGreen
        case "page4":
            controller.navigationController?.navigationBar.barTintColor = lightGreen
        case "page5":
            controller.navigationController?.navigationBar.barTintColor = lightGreen
        case "page6":
            controller.navigationController?.navigationBar.barTintColor = pink
        case "page1":
            controller.navigationController?.navigationBar.barTintColor = pink
        default:
            print("uh-oh")
        }

    }
    */
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationController?.navigationBar.barTintColor = pink
    }
    
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first, firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
}