//
//  WalkthroughPageViewController.swift
//  Tolocam
//
//  Created by Leo on 2018/10/26.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return __getViewControllers()
    }()
    
    private var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        __configurePageControl()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController)!
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController)!
        
        let subsequentIndex = viewControllerIndex + 1
        
        guard subsequentIndex < orderedViewControllers.count else {
            return nil
        }
        
        guard orderedViewControllers.count > subsequentIndex else {
            return nil
        }
        
        return orderedViewControllers[subsequentIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    private func __configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }

    private func __getViewControllers() -> [UIViewController]{
        return [Tolo.walkthroughPage1ViewController, Tolo.walkthroughPage2ViewController, Tolo.walkthroughPage3ViewController, Tolo.walkthroughPage4ViewController, Tolo.walkthroughPage5ViewController]
    }

}
