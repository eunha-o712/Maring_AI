package com.maring.api.safety;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

/**
 * maring.* 설정 바인딩. 위기 자원 목록을 보유.
 */
@ConfigurationProperties(prefix = "maring")
public class SafetyProperties {

    private List<CrisisResource> crisisResources = new ArrayList<>();

    public List<CrisisResource> getCrisisResources() {
        return crisisResources;
    }

    public void setCrisisResources(List<CrisisResource> crisisResources) {
        this.crisisResources = crisisResources;
    }
}
