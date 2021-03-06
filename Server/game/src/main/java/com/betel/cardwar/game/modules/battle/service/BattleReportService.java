package com.betel.cardwar.game.modules.battle.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.betel.asd.BaseService;
import com.betel.asd.RedisDao;
import com.betel.cardwar.game.consts.Field;
import com.betel.cardwar.game.consts.ReturnCode;
import com.betel.cardwar.game.modules.battle.ModuleConfig;
import com.betel.cardwar.game.modules.battle.model.*;
import com.betel.cardwar.game.modules.checkpoint.model.CheckPoint;
import com.betel.cardwar.game.modules.checkpoint.service.CheckPointService;
import com.betel.cardwar.game.utils.JSONUtils;
import com.betel.session.Session;
import com.betel.session.SessionState;
import com.betel.utils.IdGenerator;
import com.betel.utils.JSONArrayUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * @Description
 * @Author zhengnan
 * @Date 2020/6/22
 */
public class BattleReportService extends BaseService<BattleReport>
{
    final static Logger logger = LogManager.getLogger(BattleReportService.class);

    final static int MAX_REPORT_NUM = 10;

    @Autowired
    protected BattleReportDao dao;

    @Override
    public RedisDao<BattleReport> getDao()
    {
        return dao;
    }

    @Autowired
    protected CheckPointService checkPointService;

    /**
     * 生成战报
     *
     * @param session
     */
    private void startBattle(Session session)
    {
        CheckPoint checkPoint = getCheckPoint(session);
        if (checkPoint == null)
        {
            session.setState(SessionState.Fail);
            rspdMessage(session, ReturnCode.Checkpoint_Not_Found);
        } else
        {
            JSONObject sendJson = new JSONObject();
            //保存编组
            String battleArray = session.getRecvJson().getString(Field.BATTLE_ARRAY);
            sendJson.put(Field.BATTLE_REPORT, checkPoint.toRspdJson());
            sendJson.put(Field.BATTLE_ARRAY, battleArray);
            rspdClient(session, sendJson);
        }
    }

    /**
     * 结束战斗
     *
     * @param session
     */
    private void endBattle(Session session)
    {
        int star = session.getRecvJson().getIntValue(Field.CHAPTER_STAR);
        CheckPoint checkPoint = getCheckPoint(session);
        if (checkPoint == null)
        {
            session.setState(SessionState.Fail);
            rspdMessage(session, ReturnCode.Checkpoint_Not_Found);
        } else
        {
            checkPoint.setStar(star);
            checkPoint.setLastPassTime(now());
            checkPointService.saveCheckPoint(checkPoint);
            rspdMessage(session, ReturnCode.Checkpoint_Pass);
        }
    }

    /**
     * 生成战报
     *
     * @param session
     */
    private void generateBattleReport(Session session)
    {
        JSONObject sendJson = new JSONObject();
        sendJson.put(Field.BATTLE_REPORT, JSON.toJSON(new BattleReport()));
        rspdClient(session, sendJson);
    }

    /**
     * 保存战报
     *
     * @param session
     */
    private void saveBattleReport(Session session)
    {
        String roleId = session.getRecvJson().getString(Field.ROLE_ID);
        int chapterId = session.getRecvJson().getIntValue(Field.CHAPTER_ID);
        int roleLevel = session.getRecvJson().getIntValue(Field.ROLE_LEVEL);
        String checkpointId = session.getRecvJson().getString(Field.CHECKPOINT_ID);

        int star = session.getRecvJson().getIntValue(Field.BATTLE_STAR);
        JSONArray battleUnitArray = session.getRecvJson().getJSONArray(Field.BATTLE_UNITS);
        JSONArray reportNodeArray = session.getRecvJson().getJSONArray(Field.REPORT_NODES);
        JSONArray accountNodeArray = session.getRecvJson().getJSONArray(Field.ACCOUNT_NODES);

        CheckPoint checkPoint = checkPointService.getCheckPoint(roleId, chapterId, checkpointId);
        if (checkPoint == null)
        {
            session.setState(SessionState.Fail);
            rspdMessage(session, ReturnCode.Checkpoint_Not_Found);
        } else
        {

            List<BattleReport> battleReports = getBattleReports(session);
            battleReports.sort(Comparator.comparing(BattleReport::getId).reversed());//按添加时间排序
            if(battleReports.size() >= MAX_REPORT_NUM)//移除最老的战报
                dao.deleteEntity(battleReports.get(battleReports.size() - 1));
            BattleReport battleReport = new BattleReport();
            battleReport.setId(Long.toString(IdGenerator.getInstance().nextId()));
            battleReport.setVid(chapterId + "_" + checkpointId);//章节构成的副键
            battleReport.setRoleId(roleId);
            battleReport.setRoleLevel(roleLevel);
            battleReport.setChapterId(chapterId);
            battleReport.setCheckpointId(checkpointId);
            battleReport.setStar(star);
            battleReport.setBattleUnits(JSONUtils.getDataList(battleUnitArray, BattleUnit.class));
            battleReport.setReportNodes(JSONUtils.getDataList(reportNodeArray, ReportNode.class));
            battleReport.setAccountNodes(JSONUtils.getDataList(accountNodeArray, AccountNode.class));
            battleReport.setLastPassTime(now());
            dao.addEntity(battleReport);
            rspdMessage(session, ReturnCode.Save_Report_Success);
        }
    }


    /**
     * 获取某章节的战报列表
     * @param session
     */
    private void getBattleReportList(Session session)
    {
        List<BattleReport> battleReports = getBattleReports(session);
        battleReports.sort(Comparator.comparing(BattleReport::getId).reversed());//按添加时间排序
        List<JSONObject> sampleJsonList = new ArrayList<>();
        for (BattleReport report : battleReports)
            sampleJsonList.add(ModuleConfig.getSampleJSON(report));
        JSONObject sendJson = new JSONObject();
        sendJson.put(Field.BATTLE_REPORT_LIST, sampleJsonList);
        rspdClient(session, sendJson);
    }

    /**
     * 获取某章节的详细战报
     * @param session
     */
    private void getBattleReport(Session session)
    {
        String reportId = session.getRecvJson().getString(Field.REPORT_ID);
        BattleReport battleReport = dao.getEntity(reportId);
        JSONObject sendJson = new JSONObject();
        sendJson.put(Field.BATTLE_REPORT, battleReport);
        rspdClient(session, sendJson);
    }

    private List<BattleReport> getBattleReports(Session session)
    {
        int chapterId = session.getRecvJson().getIntValue(Field.CHAPTER_ID);
        String checkpointId = session.getRecvJson().getString(Field.CHECKPOINT_ID);
        List<BattleReport> battleReports = dao.getViceEntities(chapterId + "_" + checkpointId);
        return battleReports;
    }

    private CheckPoint getCheckPoint(Session session)
    {
        String roleId = session.getRecvJson().getString(Field.ROLE_ID);
        int chapterId = session.getRecvJson().getIntValue(Field.CHAPTER_ID);
        String checkpointId = session.getRecvJson().getString(Field.CHECKPOINT_ID);
        CheckPoint checkPoint = checkPointService.getCheckPoint(roleId, chapterId, checkpointId);
        return checkPoint;
    }
}
