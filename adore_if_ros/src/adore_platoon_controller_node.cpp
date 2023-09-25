/********************************************************************************
 * Copyright (C) 2017-2020 German Aerospace Center (DLR). 
 * Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 
 *
 * Contributors: 
 *   Anas Abulehia- initial API and implementation
 ********************************************************************************/

#include <adore_if_ros_scheduling/baseapp.h>
#include <adore_if_ros/factorycollection.h>
#include <adore/apps/lqr_controller.h>

namespace adore
{
  namespace if_ROS
  {  
    class PlatoonNode : public FactoryCollection, public adore_if_ros_scheduling::Baseapp
    {
      public:
      adore::apps::LQRController* fbc_;
      PlatoonNode(){}
      void init(int argc, char **argv, double rate, std::string nodename)
      {
        Baseapp::init(argc, argv, rate, nodename);
        Baseapp::initSim();
        FactoryCollection::init(getRosNodeHandle());
        fbc_ = new adore::apps::LQRController();

        // timer callbacks
        std::function<void()> run_fcn(std::bind(&adore::apps::LQRController::run,fbc_));
        Baseapp::addTimerCallback(run_fcn);
      }
    };
  }
}
int main(int argc,char **argv)
{
    adore::if_ROS::PlatoonNode pn;
    pn.init(argc, argv, 100.0, "adore_platoon_node");
    pn.run();
    return 0;
}